## Install

1. Run https://github.com/rhung123/Monifactory/actions/workflows/build_pr.yml with build-server and DevBuild version
    1. Go to summary and download server-build. It should be a server.zip file.
1. Follow instructions from Monifactory readme.
    1. Download 47.4.0 forge installer [here](https://files.minecraftforge.net/net/minecraftforge/forge/index_1.20.1.html).
    1. `mkdir moniserver`
    1. `mv server-build.zip forge* moniserver`
    1. `cd moniserver`
    1. `java -jar forge*.jar --installServer`
    1. `unzip server.zip`
    1. `./run.sh`
    1. `sed -i.bak 's/^eula=false$/eula=true/' eula.txt && rm eula.txt.bak`
    1. `./run.sh`
    1. add spark server jar to mods
    1. `/stop` to stop the server.
    1. set up the backup by unzipping the zip
    1. move the file under `saves` to the root server folder
    1. edit `server.properties` to the new world save name
    1. delete the old `world` folder (old save)
    1. `./run.sh`



## WinterNode
1. log into https://gcp.winternode.com/server/<>
1. Go to SFTP Details and press "Launch SFTP"
1. move all the files from `moniserver/` to the server.






## Update

In your server directory delete config-overrides, config, defaultconfig, kubejs, and mods. Then from the new Monifactory server zip copy over those same directories to replace the ones you removed. Enjoy!