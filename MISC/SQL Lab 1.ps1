Add-Type -Assembly System.Windows.Forms     ## Load the Windows Forms assembly 
## Create the main form 
Write-Host "Create form" (Get-Date)  
$form = New-Object Windows.Forms.Form 
$form.FormBorderStyle = "FixedToolWindow" 
$form.Text = "SQL Job - Enable/Disable" 
$form.StartPosition = "CenterScreen" 
$form.Width = 740 ; $form.Height = 200  # Make the form wider 
#Add Buttons- ## Create the button panel to hold the OK and Cancel buttons 
$buttonPanel = New-Object Windows.Forms.Panel  
    $buttonPanel.Size = New-Object Drawing.Size @(400,40) 
    $buttonPanel.Dock = "Bottom"    
    $cancelButton = New-Object Windows.Forms.Button  
        $cancelButton.Top = $buttonPanel.Height - $cancelButton.Height - 10; $cancelButton.Left = $buttonPanel.Width - $cancelButton.Width - 10 
        $cancelButton.Text = "Cancel" 
        $cancelButton.DialogResult = "Cancel" 
        $cancelButton.Anchor = "Right" 
    ## Create the OK button, which will anchor to the left of Cancel 
    $okButton = New-Object Windows.Forms.Button   
        $okButton.Top = $cancelButton.Top ; $okButton.Left = $cancelButton.Left - $okButton.Width - 5 
        $okButton.Text = "OK" 
        $okButton.DialogResult = "Ok" 
        $okButton.Anchor = "Right" 
    ## Create the Stutus button, which will anchor to the left of OK 
    $StatusButton = New-Object Windows.Forms.Button   
        $StatusButton.Top = $okButton.Top ; $StatusButton.Left = $okButton.Left - $StatusButton.Width - 5 
        $StatusButton.Text = "Status" 
        $StatusButton.DialogResult = "Ok" 
        $StatusButton.Anchor = "Right" 
    ## Add the buttons to the button panel 
    $buttonPanel.Controls.Add($okButton) 
    $buttonPanel.Controls.Add($cancelButton)
    $buttonPanel.Controls.Add($StatusButton) 
## Add the button panel to the form 
$form.Controls.Add($buttonPanel) 
## Set Default actions for the buttons 
$form.AcceptButton = $okButton          # ENTER = Ok 
$form.CancelButton = $cancelButton      # ESCAPE = Cancel 
 

## Label and TextBox  
## Computer/Host Name 
$lblHost = New-Object System.Windows.Forms.Label   
    $lblHost.Text = "Host Name:"  
    $lblHost.Top = 10 ; $lblHost.Left = 5; $lblHost.Width=150 ;$lblHost.AutoSize = $true 
    $form.Controls.Add($lblHost)    # Add to Form 
    # 
    $txtHost = New-Object Windows.Forms.TextBox  
    $txtHost.TabIndex = 0 # set Tab Order 
    $txtHost.Top = 10; $txtHost.Left = 160; $txtHost.Width = 120;  
    $txtHost.Text = $env:computername   # Use Corrent computer name as default 
    $form.Controls.Add($txtHost)    # Add to Form 
    # Obtain Value with: $txtHost.Text 

## Create the OS Image ComboBox 
$lblSqlJobs = New-Object System.Windows.Forms.Label; $lblSqlJobs.Text = "SQL Jobs List:"; $lblSqlJobs.Top = 60; $lblSqlJobs.Left = 5; $lblSqlJobs.Autosize = $true  
    $form.Controls.Add($lblSqlJobs)    # Add to Form 
$cbSqlJobs = New-Object Windows.Forms.ComboBox ; $cbSqlJobs.Top = 60; $cbSqlJobs.Left = 160; $cbSqlJobs.Width = 400 
    
    $SQLJobList = Get-SqlAgentJob -ServerInstance LTEAR06371  # Download a list of VM OS Images from the Azure Portal 
    [void] $cbSqlJobs.BeginUpdate() # This tells the control to not update the display while processing (saves time) 
    $i = 0 ; $iSelect = -1 
    foreach ($element in $SQLJobList) {  
        #$thisElement = $i.ToString() +" :: " + $element.name 
        [void] $cbSqlJobs.Items.Add($element.name)  
        $i ++ 
        } 
    $cbSqlJobs.SelectedIndex = $iSelect  # Set the default SelectedIndex 
    [void] $cbSqlJobs.EndUpdate()  # update the control with all the data that was added 
    $form.Controls.Add($cbSqlJobs) 
    #Write-Host "Finished building list of databses" (Get-Date) -ForegroundColor Green 
    # Obtain Value with: $cbSqlJobs.SelectedItem 
    # Obtain index: $cbSqlJobs.SelectedIndex 
    # Obtain Access to entire SELECTED element from original Array with: $SQLJobList[$cbSqlJobs.SelectedIndex].????? 

## Finalize Form and Show Dialog   
$form.Add_Shown( { $form.Activate(); $okButton.Focus() } )  #Activate and Set Focus 
$result = $form.ShowDialog()          ## Show the form, and wait for the response 

# Finished with Dialog Box, Now let's see what the user did... 
#$Result 
if($result -eq "OK") 
    {   # Copy variables and use them as you desire... 
    #$txtHost.Text 
    #$locListBox.SelectedItem 
    Write-Host "Job Selected is :" $cbSqlJobs.SelectedItem
    #Write-Host $cbSqlJobs.SelectedIndex 
    #$SQLJobList[($cbImage1.SelectedIndex)].ImageName 
    #$SQLJobList[($cbImage1.SelectedIndex)].Label 
} 
elseif($result -eq "Status")
{Write-Host "Job Selected is :" $cbSqlJobs.Created}
else {Write-Host "Cancel"} 
