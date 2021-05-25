
#%% 
import os
import toml

from pprint import pprint

# cfg = toml.load(os.path.relpath("./configuration.toml"))  

cfg = toml.load("./configuration.toml")  

pprint(cfg)

#%%

type(cfg)
print(cfg['Worker'])
pprint(cfg['Worker'])

#%%

print(type(cfg['Clients']))
cfg['Clients']['Metadata']

#%%
type(cfg['Clients']['Metadata']['Port'])
