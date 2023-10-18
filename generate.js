const fs = await import('fs');
const f=process.argv[2];
if (f) {
    let bash_script, node_script;
    if (fs.existsSync(f+'.sh'))
        bash_script = fs.readFileSync(f+'.sh').toString();
    if (fs.existsSync(f+'.js'))
        node_script = fs.readFileSync(f+'.js').toString();
const jsh = 
`#!/usr/bin/env node-jsh

if (process.title=="node-jsh") {
    const { spawn } = await import('child_process')
    const bash_script=\`${bash_script.replace(/\\/g,'\\\\').replace(/`/g,'\\`').replace(/\$\{/g,'$\\{')}\`
    await spawn('bash', ['-c', bash_script, ...process.argv.slice(1)], { stdio: 'inherit' });
}
    ${node_script}`;
    fs.writeFileSync(process.argv[3]||(f+`.jsh`), jsh);
    const p = await import('child_process');
    p.execSync(`chmod +x ${process.argv[3]||(f+`.jsh`)}`);
}