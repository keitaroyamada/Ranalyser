%% macOS Code Signing and Notarization Automation Script (Anonymous Version)

% --- CONFIGURATION: Fill in your details here ---
teamID = "YOUR_TEAM_ID"; % e.g., "HKC3R428L6"
appleID = "YOUR_EMAIL@example.com"; 
appPassword = "xxxx-xxxx-xxxx-xxxx"; % App-Specific Password from appleid.apple.com
devID = sprintf("Developer ID Application: Your Name (%s)", teamID);

appName = 'Ranalyser';
appFile = 'Ranalyser.app';
installerName = 'RanalyserInstaller.app';
zipName = 'RanalyserInstaller.zip';
entitlements = 'entitlements.plist';
appVersion = '5.2.0';

%% 1. Signing the Application Bundle
fprintf('--- Step 1: Signing Application Components ---\n');
targets = { ...
    fullfile(appFile, 'Contents/MacOS/applauncher'), ...
    fullfile(appFile, 'Contents/MacOS/Ranalyser'), ...
    fullfile(appFile, 'Contents/MacOS/prelaunch'), ...
    appFile ...
};

for i = 1:length(targets)
    fprintf('Signing: %s\n', targets{i});
    cmd = sprintf('codesign --verbose=4 --force --timestamp --options runtime -s "%s" --entitlements %s "%s"', ...
        devID, entitlements, targets{i});
    [status, cmdout] = system(cmd);
    disp(cmdout);
    if status ~= 0
        error('Error: Failed to sign %s', targets{i});
    end
end

%% 2. Creating the Installer
fprintf('--- Step 2: Creating the Installer ---\n');
opts = compiler.package.InstallerOptions('ApplicationName', appName);
opts.Version = appVersion;
opts.Summary = 'Application for analysis'; 

% Execute MATLAB compiler function
compiler.package.installer({appFile}, 'buildresult.json', 'Options', opts);
fprintf('Installer creation completed.\n');

%% 3. Signing the Installer
fprintf('--- Step 3: Signing the Installer Package ---\n');
cmd_sign_inst = sprintf('codesign --force --options runtime --timestamp --sign "%s" %s', ...
    devID, installerName);
[status, cmdout] = system(cmd_sign_inst);
disp(cmdout);
if status ~= 0, error('Error: Failed to sign the installer.'); end

%% 4. Notarization
fprintf('--- Step 4: Submitting to Apple Notary Service (Waiting for result) ---\n');

% Compress for upload
cmd_zip = sprintf('ditto -c -k --rsrc --keepParent %s %s', installerName, zipName);
system(cmd_zip);

% Upload and wait
cmd_notary = sprintf('xcrun notarytool submit %s --apple-id "%s" --password "%s" --team-id %s --wait', ...
    zipName, appleID, appPassword, teamID);
[status, cmdout] = system(cmd_notary);
disp(cmdout);

%% 5. Stapling the Ticket
if status == 0 && (contains(cmdout, 'Accepted') || contains(cmdout, 'success'))
    fprintf('--- Step 5: Notarization successful. Stapling ticket ---\n');
    
    system(sprintf('xcrun stapler staple %s', installerName));
    system(sprintf('xcrun stapler staple %s', appFile));
    
    fprintf('SUCCESS: Workflow completed. The installer is ready for distribution.\n');
else
    fprintf('ERROR: Notarization failed. Check the output above for details.\n');
end