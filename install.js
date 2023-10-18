import fs from 'fs';
import os from 'os';
import path from 'path';
import p from 'child_process';

// The name of the script
const j = 'j1st';

// Make the script executable (Linux/macOS)
if (os.platform() !== 'win32') {
    const destinationDir = '/usr/local/bin'; // You can use a different directory if you prefer

    // Create the destination directory if it doesn't exist
    if (!fs.existsSync(destinationDir)) {
        fs.mkdirSync(destinationDir);
    }

    // Copy the Bash script to the destination directory
    p.execSync(`node jsh/generate ${j} ${path.join(destinationDir, j)}.jsh.mjs`);
    fs.copyFileSync("config.json", path.join(os.homedir(), '.'+j, 'config.json'));
    fs.copyFileSync("config-data-only.js", path.join(os.homedir(), '.'+j, 'config-data-only.js'));
    if (!fs.existsSync(`/usr/local/bin/${j}`)) {
        p.execSync(`sudo ln -s /usr/local/bin/${j}.jsh.mjs /usr/local/bin/${j}`);
    }
    p.execSync(`chmod +x ${path.join(destinationDir, j)}`);
    console.log(`${j} has been installed to ${destinationDir}`);
    console.log('Make sure that the destination directory is in your PATH.');
    if (!fs.existsSync(`/usr/local/bin/node-jsh`)) {
        p.execSync(`sudo ln -s $(which node) /usr/local/bin/node-jsh`);
    }
} else {
    // Define the custom directory in AppData\Local
    const customDir = path.join(os.homedir(), 'AppData', 'Local', j); 

    // Create the custom directory if it doesn't exist
    if (!fs.existsSync(customDir)) {
        fs.mkdirSync(customDir, { recursive: true });
    }

    fs.copyFileSync(customScriptPath, path.join(customDir, customScriptName));

    // Create the batch script content
    const scriptContent = `@echo off\nnode "${customScriptPath}" %*`;
    fs.writeFileSync(path.join(customDir, j), scriptContent);

    // Add the custom directory to the system's PATH
    try {
        execSync(`setx PATH "%PATH%;${customDir}"`, { stdio: 'ignore' });
    } catch (error) {
        console.error('Error adding the custom directory to PATH.');
        process.exit(1);
    }
}