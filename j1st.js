let j1ST=()=>{};
if (process.title=="node") {
    const fs = await import('fs');
    const os = await import('os');
    const path = await import('path');
    const readline = await import('readline');
    const j = `j1st`;
    const __filename = process.argv[1];
    const configStr = fs.readFileSync(path.join(os.homedir(), '.'+j, 'config.json'));
    let j1st = '';
    let envVar = j.toUpperCase();
    let onEnterVar = "ONENTER"
    try {
        const config = JSON.parse(configStr);
        if (config && config.environmentalVariables) {
            envVar = config.environmentalVariables.nameSpecifier || envVar;
            onEnterVar = config.environmentalVariables.defaultConfirmation || onEnterVar;
        }
    } catch (ex) {
        //do nothing
    }
    const version = process.env[envVar];
    let argument = process.argv.length > 2 ? process.argv[process.argv.length-1].toLowerCase() : '';
    let onEnterChoice = (argument.match(/[ryn]/g) ? argument : false) || (process.env[onEnterVar] || 'n').toLowerCase();

    function askForConfirmation(question) {
        return new Promise((resolve, reject) => {
            const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
            });
            const options = (` (y/n/r): `).replace(onEnterChoice,onEnterChoice.toUpperCase());
            console.log(question+options);
            rl.question('', (answer) => {
                rl.close();
                if (answer=='') {
                    answer=onEnterChoice || '';
                }
                if (answer.slice(0,1).toLowerCase() === 'y') {
                    resolve(true);
                } else if (answer.slice(0,1).toLowerCase() === 'n') {
                    resolve(false);
                } else if (answer.slice(0,1).toLowerCase() === 'r') {
                    resolve(1);
                }
            });
        });
    }

        
    j1ST = async (filename) => {
        if (process.argv[process.argv.length-1]=='--config-data-only') {
            if (!filename)
                return {
                    configDataOnly: j1ST
                };
            else
                argument="!"
        } 
        
        filename=filename||__filename;
        if (version)
            j1st = '.' + version; 
        let jsonFilename = (filename).replace(/\.(js|mjs)$/g,(j1st+=".json"));

        if (!jsonFilename.includes(j1st))
            jsonFilename+=j1st;
        let json = {};
        try {
            if (fs.existsSync(jsonFilename)){
                const jsonString = fs.readFileSync(jsonFilename, "utf8");
                json = tryParse(jsonString) || {};
            } else {
                fs.writeFileSync(jsonFilename,`{\n\n}`);
            }
            console.log(jsonFilename+":")
            console.dir(json, {depth: null, colors: true})
        } catch (ex) {
            console.error(ex);
        }

        if (argument=='!' || argument=='!!')
            process.exit(0);
        if (argument!='+++') {
            const confirm = await askForConfirmation(`Are you sure you want to run '${filename}' with these parameters?`);
            console.log();
            if (confirm===false) {
                console.log("Process interrupted.")
                process.exit(1);
            } else if (confirm===1) {
                return await j1ST();
            }
        }
        console.log("Program started.")
        return json;
    }

    const tryParse = (str) => {
        let result = {};
        try {
            result = JSON.parse(str) || {};
        } catch (ex) {
            //do nothing;
        }
        return result;
    }
}
export default await j1ST();