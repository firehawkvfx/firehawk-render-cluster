import json
from Deadline.Scripting import ClientUtils, RepositoryUtils

# execute with:
# deadlinecommand -ExecuteScriptNoGui "update_spot.py"


try:
    with open('/home/ubuntu/config_generated.json') as json_file:
        configs = json.load(json_file)
        # config = str({"test":"test"})
        # configs = json.loads(config)
        if not configs:
            raise Exception("No Spot Fleet Request Configuration found.")

        RepositoryUtils.AddOrUpdateServerData("event.plugin.spot", "Config", json.dumps(configs))
except Exception as e:
    print(e)
    raise e