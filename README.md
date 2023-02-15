benchmarks and associated code for schematometria project

these benchmarks are based on a database dump of the gcloud release party cluster database. most performance issues have been encountered either for the first time or only on that database. This makes it a good test case for evaulating performance of different schemata and queries.

I was able to load the database into my local devcluster via the following steps.

- start up devcluster
- type a syntax error into the `master` code. save and restart devcluster (pressing 1 then 3 in the terminal pane where devcluster is running). this makes it so that the `determined_db` container is running, but the cluster is not accessing it. this makes it more likely for the following to be successful

- download [this zip](https://hpe-my.sharepoint.com/:u:/p/trent_watson/EaIhHJRxLW1Il2rAr6aK7K8B-zPSk8NE1dUunHaxiefxfQ?e=INn1g5) and extract the `.sql` file (it will be around 16GB). run the below command to restore the database from the dump (this may take as long as an hour).

```
psql -h localhost -U postgres -f gcloud-2023_02_10_10_39_15-dump.sql
```

it should be successful except for a few error messages about `cloudsqlsuperuser` or other roles/permissions assignments. if there are errors about unique keys, try deleting the database and starting again.

right now the data is in the database `postgres`. to move it to determined, do `psql -h localhost -U postgres`, and then from the `psql` prompt:

```
CREATE DATABASE temp
\c temp
DROP DATABASE determined
ALTER DATABASE postgres RENAME TO determined;
```

then remove the syntax error and restart `devcluster`. the new data from the database dump should be reflected in the WebUI.
