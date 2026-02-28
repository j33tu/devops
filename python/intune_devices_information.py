# First we would try to fetch the Token from Azure using a service principal 
import requests
import os
import requests
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv

# Load environment variables from a .env file (ensure .env is in your .gitignore   )
load_dotenv()

# Fetch token using DefaultAzureCredential
try:
    cred = DefaultAzureCredential()
    at = cred.get_token("https://graph.microsoft.com/.default")
    access_token = at.token
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    print("✅ Token acquired successfully from Azure")
except Exception as e:
    print(f"❌ Failed to acquire token: {e}")
# defining parameters 

## use your secret here , if using cicd specify a cicd env variable / secret and reference that / .env file but make sure you put that into gitignore file
# Here end point is where the data would be available , this is from microsoft API documentation
devices_url = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"
# saving the response
devices_res = requests.get(devices_url, headers=headers)
#fetch all devices from the response we got , jason response is mostly a python dictionary which you could use as data object and proces further 
devices = devices_res.json().get('value', [])
# 200 is a good response, query or call was successfull
devices_res

#lets move data to a variable then we can create a datafraem out of that 
devices = devices_res.json().get('value', [])
devices
# check our data 
device_data = pd.DataFrame(devices)

# check all the columns you are getting from that API call about managed devices
print(device_data.columns.tolist())

df_final=device_data
# pymysql acts as the translator. It allows your Python code to send SQL commands (like INSERT, SELECT, or CREATE TABLE) to a MySQL or MariaDB server.
# pip install pymysql
from urllib.parse import quote_plus
# get a database connection ready so we can use that to authorize when we will upload data to database
import os
from sqlalchemy import create_engine
from urllib.parse import quote_plus
from dotenv import load_dotenv

# 1. Force load the .env file
load_dotenv()
# 1. Credentials (make sure these variables are set or replaced with strings)
DB_USER = os.getenv("DB_USER", "g2admin")
DB_PASS = os.getenv("DB_PASS") # specify in .env file or cicd pipeline varaible and reference
DB_HOST = os.getenv("DB_HOST", "g2-prd-mysql-wus.mysql.database.azure.com")
DB_NAME = os.getenv("DB_NAME", "intune_db")

# 2. Encode password and create the engine
safe_password = quote_plus(DB_PASS)
connection_string = f"mysql+pymysql://{DB_USER}:{safe_password}@{DB_HOST}/{DB_NAME}"
engine = create_engine(connection_string)

# 3. Now run your TRUNCATE logic
try:
    with engine.connect() as conn:
        conn.execute(text("TRUNCATE TABLE managed_devices;"))
        conn.commit()
        print("🧹 Table cleared. Ready for fresh data.")
except Exception as e:
    print(f"❌ Error clearing table: {e}")


import json
import pandas as pd
from sqlalchemy import text

# 1. Create a copy to keep your original data safe
df_push = device_data.copy()

# 2. Convert Complex Objects (Lists/Dicts) to JSON Strings
# This fixes the ProgrammingError (1064) caused by [] or {}
for col in df_push.columns:
    # We check if the column contains objects like lists or dictionaries
    if df_push[col].apply(lambda x: isinstance(x, (list, dict))).any():
        df_push[col] = df_push[col].apply(lambda x: json.dumps(x) if x is not None else None)

# 3. Standardize Dates for MySQL
# This removes the 'T' and 'Z' that cause the 'Incorrect datetime value' error
for col in df_push.columns:
    if 'Date' in col or 'Time' in col:
        df_push[col] = pd.to_datetime(df_push[col], errors='coerce').dt.tz_localize(None)

# 4. Handle Booleans & Nulls
# MySQL TINYINT(1) works best with 1, 0, or None
for col in df_push.columns:
    if df_push[col].dtype == 'bool':
        df_push[col] = df_push[col].astype(int)

# move final data to a datafram
df_push=df_push

# lets try to export and push our data to our database which is a my sql database runinng in azure 
try:
    # index=False is critical so Pandas doesn't try to insert an extra 'index' column
    df_push.to_sql('managed_devices', con=engine, if_exists='append', index=False)
    print(" Success! Your Intune data is now in the Azure MySQL 'managed_devices' table.")
    
    # Let's verify by printing the first few rows from the DB itself
    from sqlalchemy import text
    with engine.connect() as conn:
        result = conn.execute(text("SELECT COUNT(*) FROM managed_devices"))
        print(f" Total records now in DB: {result.scalar()}")

except Exception as e:
    # If this fails with a 'Duplicate Entry' error, it means the devices are already there!
    print(f" Database Push Error: {e}")
