import json
from Deadline.Scripting import ClientUtils, RepositoryUtils

# execute with:
# deadlinecommand -ExecuteScriptNoGui "update_spot.py"

import argparse

def __main__():
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('--template-path', help='The path to your spot fleet template to configure deadline with')
        args = parser.parse_args()
        print('template path: {}'.format(args))

        with open('/home/ubuntu/config_generated.json') as json_file:
            configs = json.load(json_file)
            if not configs:
                raise Exception("No Spot Fleet Request Configuration found.")

            RepositoryUtils.AddOrUpdateServerData("event.plugin.spot", "Config", json.dumps(configs))
    except Exception as e:
        print(e)
        raise e