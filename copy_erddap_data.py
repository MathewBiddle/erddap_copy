from erddapy import ERDDAP
import pandas as pd

from erddapy import servers

cencoos_servers = {k: v.url for k, v in servers.items() if 'cencoos' in v.url}

print(f'{cencoos_servers}')

df_out = pd.DataFrame()

for s, url in cencoos_servers.items():

    e = ERDDAP(server=url, protocol="tabledap")

    kw = {"cdm_data_type": "TimeSeries"}

    url = e.get_search_url(response="csv", **kw)

    df = pd.read_csv(url)

    df_out = pd.concat([df_out,df], ignore_index=True)

# lets just use the first university one as a test
dset = df_out.loc[df_out['Institution'].str.contains("University")].iloc[0]

#print(dset)

# Go get the data
e.dataset_id = dset['Dataset ID']

print(e.get_download_url(response='nc'))

e.download_file(file_type="nc")
