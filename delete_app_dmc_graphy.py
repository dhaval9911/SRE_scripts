import os
import sys
import json
import time
import tarfile
import tempfile
import argparse
import subprocess

class DelFromInstallationGraph:
    def __init__(self, app_id):
        self._app_id = app_id
        self._kvstore_backup_path = '/opt/splunk/var/lib/splunk/kvstorebackup/'
        self._kvstore_backup = f'kvstore_dump_{time.time()}'
        self._kvstore_tar = self._kvstore_backup + '.tar.gz'
        self._tmp_path = tempfile.TemporaryDirectory()
        self._graphs_path = 'dmc/graphs/graphs0.json'
        self._graphs_tar = f'graphs{time.time()}.tar.gz'

    def check_if_app_is_present(self, installation_graph, app_to_remove):
        flag = False
        for target in installation_graph['graph'].keys():
            apps = installation_graph['graph'][target]['apps']
            apps_set = set(apps)
            if app_to_remove in apps_set:
                flag = True
        return flag

    def latest_graph_with_staged_false(self, graphs):
        # Remove app entry from last installation graph
        while True:
            latest_graph = graphs.pop()
            if latest_graph['staged']:
                continue
            else:
                return latest_graph

    def remove_app_from_dmc_graphs_file(self):
        input_filepath = self._tmp_path.name + '/' + self._graphs_path
        with open(input_filepath, 'r') as f:
            graphs = json.load(f)
        latest_graph = self.latest_graph_with_staged_false(graphs)
        app_to_remove = self._app_id
        if not self.check_if_app_is_present(latest_graph, app_to_remove): # checks if app is present in Installation graph
            print(f"App {app_to_remove} is not present in installation graph")
            return False
        latest_graph['version'] = latest_graph['version'] + 1 #Bumping the version

        # loop through targetWorkloads in graph
        for target in latest_graph['graph'].keys():
            apps = latest_graph['graph'][target]['apps']
            old_app_set = set(apps)

            print("Attempting to remove {} from {} installation graph version {}.".format(app_to_remove, target, latest_graph['version']))
            latest_graph['graph'][target]['apps'] = {k: v for k, v in apps.items() if k != app_to_remove}
            app_set = set(latest_graph['graph'][target]['apps'])
            if(old_app_set == app_set):
                print("App {} is not present on {}. No need to remove from there!".format(app_to_remove, target))
                continue
            print("Successfully removed {} from {} installation graph version {}.".format(app_to_remove, target, latest_graph['version']))
        graphs.append(latest_graph)
        with open(input_filepath, 'w') as f:
            json.dump(graphs, f, separators=(', ', ' : '))
        print("Successfully removed app from installation graph's version: {} and saved it to the file: {}".format(latest_graph['version'], input_filepath))
        return True

    def copy_graphs_tar_to_kvstore_backup(self):
        full_graphs_path = os.path.join(self._tmp_path.name, self._graphs_path)
        full_graphs_tar = os.path.join(self._kvstore_backup_path, self._graphs_tar)
        with tarfile.open(full_graphs_tar, 'w:gz') as tar:
            tar.add(full_graphs_path, arcname=self._graphs_path)

    def restore_graph(self):
        subprocess.check_output(f'splunk restore kvstore -archiveName {self._graphs_tar} -collectionName graphs -appName dmc', shell=True)
        print('App deleted successfully \nRestored Updated KVStore')

    def backup_dmc_kvstore_and_extract(self):
        subprocess.check_output(f'splunk backup kvstore -archiveName {self._kvstore_backup} -appName dmc', shell=True)
        print(f'KVStore Backup: {self._kvstore_tar}')
        while not os.path.exists(self._kvstore_backup_path + self._kvstore_tar):
            time.sleep(1)
        try:
            with tarfile.open(self._kvstore_backup_path + self._kvstore_tar) as tar:
                tar.extract(self._graphs_path, self._tmp_path.name)
                return True
        except tarfile.ReadError:
            raise Exception('Error in reading tarfile')
        except tarfile.ExtractError:
            raise Exception('Failed to extract files from the KVStore Backup created.  Please retry.')

def main(args):
    app_id = args.app_to_remove
    del_app_from_installation_graph = DelFromInstallationGraph(app_id)
    del_app_from_installation_graph.backup_dmc_kvstore_and_extract() # Take backup of KVStore and untar in TMP_PATH folder
    if not del_app_from_installation_graph.remove_app_from_dmc_graphs_file(): # Remove the app from graphs0.json
        sys.exit(-1)
    del_app_from_installation_graph.copy_graphs_tar_to_kvstore_backup() # Copy graphs.tar.gz to ~/var/lib/splunk/kvstorebackup/
    if not args.dryrun:
        del_app_from_installation_graph.restore_graph() # Restore graphs0.json in KVStore
    
if __name__ == '__main__':
    description = '''Removes app_id from DMC's installation graph.\n
    WARNING: This script only valid on Cluster Manager in Splunk Classic Cloud.'''

    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('app_to_remove',
                        metavar='app-id-to-remove',
                        type=str,
                        help='Provide id of the app to be removed from installation graph eg. python delete_app_from_installation_graph.py <app_id>')
    parser.add_argument("--dryrun", action="store_true",
                    help="Attempts to delete app from kvstore but doesn't apply changes")
    args = parser.parse_args()
    main(args)

