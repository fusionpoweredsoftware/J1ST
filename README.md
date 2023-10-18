# J1ST

## Overview
J1ST, short for JSON 1ST, is a Node.js tool for linting and running JS files. It helps in the verification of parameters by displaying them before the program is run, organizing them into a JSON file with the same base name as the JS file, and prompting the user for confirmation.

## Why J1ST?
J1ST was created to eliminate the risk of accidentally breaking code due to parameter tweaking. While command-line arguments can mitigate this issue to some extent, they are not ideal for multi-line editing and can be cumbersome to manage. J1ST allows developers to specify parameters in a JSON file, making it easier to manage complex configurations. Additionally, it has the option to log parameters used at runtime, providing a clear history of how your code was executed. With J1ST, you get the best of both worlds: the flexibility of a text editor for parameter configuration and the accountability of a logged history.

## Installation
To make the tool accessible, run:

```bash
make
```

## Usage
Run your Node.js file using:
```bash
j1st <file.js> [flags]
```

The linter is always called before a file is run to ensure that j1st is being used in the file. The entire directory of JS files is linted, not just the JS program being run. To ignore files, add them to the `.j1st-ignore` list or use the `-i` flag. To unignore, use the `-u` flag. You can either specify a JS file to run like `j1st <file.js>`, or simply call `j1st` to get a list of any un-ignored files in the current directory which are not using the J1ST module.

### Flags
- **-i [file1] [file2] [file3] [etc]**: Add files to the ignore list.  
  Use this flag to add specific files to the ignore list, so they won't be linted. For example, `jist -i ignoreme1.js ignoreme2.js`
  
- **-u  [file1] [file2] [file3] [etc]**: Remove files from the ignore list.  
  Use this flag to remove specific files from the ignore list, allowing them to be linted again. `jist -u un-ignoreme1.js un-ignoreme2.js`
  
- **-v**: Enable verbose output for the linter.  
  Enables verbose output, listing all JS files using J1ST and those not using it but are either ignored or missing the J1ST module line.
  
- **-s**: Suppress linter output.  
  Suppresses the output of the linter, making it silent.
  
- **-a [arguments]**: Pass additional arguments into the JS file.  
  Pass additional arguments into the JavaScript file you're calling. For example, `j1st example.js -a "arg1 arg2"`.

- **-e**: Edit the config while running the program.  
  Opens the editor specified in `~/.j1st/config.json` to edit the configuration file associated with the JS file you're running.

- **-E**: Edit the config without running the program.  
  Opens the editor specified in `~/.j1st/config.json` to exclusively edit the configuration file without executing the program.

- **-p**: Edit the program itself.  
  Opens the editor specified in `~/.j1st/config.json` to edit the program file you're running.
  
- **-n [specifier]**: Specify name for the configuration file.  
  Specifies the name for the configuration file to be accessed. For example, `j1st example.js -n test` will use `example.test.json` instead of `example.json`.
  
- **-r**: Enable repeat mode.  
  Enables repeat mode. The Node.js file will be repeatedly called until 'a' is pressed for abort.

- **-l [path]**: Enable logging to a file.  
  Use this flag to log the output of the script to a file. If an optional path is provided, it specifies where the log file will be saved. If the path ends with `.log`, it's treated as the log filename; otherwise, it's treated as a directory. For example, `j1st example.js -l /logs` would log the output to `/logs/example.js.log`.

- **-L [path]**: View the log file in the editor.  

### Additional Features
- You can set the environmental variable `J1ST` (or whatever the `"nameSpecifier"` variable in your `config.json` is set to; it's `J1ST` by default) to set the default name specifier. This will be overridden if the `-n` flag is invoked.
- When using the J1ST module in your code, the JSON configuration file and its contents are displayed at the start. A prompt will ask for user confirmation to proceed. Enter `'Y'` to continue, `'N'` to interrupt, or `'R'` to re-confirm after modifying the configuration.
- You can pass `'Y'`, `'N'`, or `'R'` as the last argument to set the default confirmation value. For example, `j1st example.js -a 'arg1 arg2 arg3 y'` will use `'Y'` as the default when hitting enter.
- The `ONENTER` environmental variable (or whatever the "defaultConfirmation" variable in your `config.json` is set to; it's `ONENTER` by default) can be used to set the default choice when starting the program. This will be overridden if the `-a` flag is invoked with one of the three options (`'Y'`, `'N'`, `'R'`) as the last argument.
- Pass `"!"` or `"!!"` into the program as its last argument to only display information about the configuration file and not run the program. E.g., `j1st example.js -a !`
- Pass `"+++"` into the program as its last argument to run the program without any confirmation. E.g., `j1st example.js -a +++`
- To edit the configuration file of the program you're running, you can use a pipe like so: `node example.js | j1st`. 
- To supply a default behavior for the confirmation prompt while editing the configuration, use `"!!"` before the pipe: `node example.js !!| j1st`. This will interrupt the program before going past the confirmation point.

### Log File Specification with `-l` and `-L`
Both the `-l` and `-L` flags accept an optional path parameter to specify the log file's location. The behavior varies depending on whether the path ends with `.log`:

- **With `.log`**: If the path ends with `.log`, it's treated as the complete log filename.  
  Example: `j1st example.js -l /logs/my_log.log` will log the output to `/logs/my_log.log`.

- **Without `.log`**: If the path doesn't end with `.log`, it's treated as a directory. The log file will be created in that directory and named after the script with a `.log` extension.  
  Example: `j1st example.js -l /logs` will log the output to `/logs/example.js.log`.

This feature allows you greater flexibility in managing your log files.

### Linting Requirements
- The `require` or `import` J1ST module line must appear in the first line of the code to pass the linter.

For more details, refer to the `j1st.sh` file.

## Configuration
Settings for each JavaScript file can be specified in a JSON file with the same base name.

## Platform Compatibility
This tool has been tested on macOS and is not guaranteed to work on Windows.

## Contributing
If you'd like to contribute, please fork the repository and create a pull request, or open an issue for discussion.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
