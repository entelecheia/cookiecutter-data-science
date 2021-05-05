# %%
import os
import sys
import platform

print(platform.system())
print(sys.version)
print(sys.executable)
# %%
# pip install python-dotenv
from dotenv import load_dotenv, find_dotenv

# find .env automagically by walking up directories until it's found
dotenv_path = find_dotenv()

# load up the entries as environment variables
load_dotenv(dotenv_path)

print(os.environ.get("ID"))
print(os.environ.get("PWD"))
# %%
