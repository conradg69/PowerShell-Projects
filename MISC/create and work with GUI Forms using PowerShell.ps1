<#   
================================================================================ 
 Name: SampleForm.ps1 
 Purpose: Demonstrate how create and work with GUI Forms using PowerShell 
 Author: Dan Stolts – dstolts&&microsoft.com - http://ITProGuru.com 
 Description: Shows how to create log Forms, add labels, text boxes, panels, comboboxes, PickLists, and more 
    Shows how to populate all fields including picklists and combobox lists and work with properties  
    Shows how to populate and work with array objects.   
    Uses Azure commands to populate list data.   
    Shows how to work with the results from the dialog and the changes made to the form objects 
Syntax/Execution: Copy portion of script you want to use and paste into PowerShell (or ISE)  
 Disclaimer: Use at your own Risk!  See details at http://ITProGuru.com/privacy  
 Limitations:  
    * Must Run PowerShell (or ISE)  
    * UAC may get in the way depending on your settings (See: http://ITProGuru.com/PS-UAC) 
    * Requires PowerShell Azure Module (see http://itproguru.com/AzurePowerShell) 
# video of Script https://channel9.msdn.com/Series/GuruPowerShell 
# More scripts from Dan Stolts "ITProGuru" at http://ITProGuru.com/Scripts 
 ================================================================================ 
#>  
Add-Type -Assembly System.Windows.Forms     ## Load the Windows Forms assembly 
## Create the main form 
Write-Host "Create form" (Get-Date)  
$form = New-Object Windows.Forms.Form 
$form.FormBorderStyle = "FixedToolWindow" 
$form.Text = "PowerShell Custom GUI Window" 
$form.StartPosition = "CenterScreen" 
$form.Width = 740 ; $form.Height = 380  # Make the form wider 
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
        $okButton.Text = "Ok" 
        $okButton.DialogResult = "Ok" 
        $okButton.Anchor = "Right" 
    ## Add the buttons to the button panel 
    $buttonPanel.Controls.Add($okButton) 
    $buttonPanel.Controls.Add($cancelButton) 
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
 
## ListBox - Fill with Data From Azure Location Name 
$lblLoc = New-Object System.Windows.Forms.Label   
    $lblLoc.Text = "Azure Loation:"; $lblLoc.Top = 50; $lblLoc.Left = 5; $lblLoc.Autosize = $true  
    $form.Controls.Add($lblLoc)  
    Write-Host "Building List of available Locations" (Get-Date) -ForegroundColor Green 
    # Listbox for Location Name 
    $locListBox = New-Object System.Windows.Forms.ListBox  
        $locListBox.Top = 50; $locListBox.Left = 160; $locListBox.Height = 120 
        $locListBox.TabIndex = 1 
        # we need to populate the listbox... Example: $objListBox.Items.Add("Item 1 Test Do NOT USE") 
        # in our case, we will use a call to Azure for our "list" 
        $LocArray = Get-AzureLocation # | Format-list SubscriptionName, IsDefault, SubscriptionId 
        $i=0   # Counter 
        foreach ($element in $LocArray) { # Loop through Azure list and add to listbox 
            [void] $locListBox.Items.Add($element.name)  # Add element to listbox 
            # Using this looping, You can also do other line item processing if needed :) 
            if ($element.name -eq "East US 2") { [void] $locListBox.SetSelected($i,$true) } # Set Default 
            $i ++ 
        } 
         
        $form.Controls.Add($locListBox) #Add listbox to form 
        Write-Host "Finished Getting Locations" (Get-Date) -ForegroundColor Green 
        # Obtain Value with: $locListBox.SelectedItem 
 
## CheckBox 
$chkThis = New-Object Windows.Forms.checkbox 
    $chkThis.Left = 5; $chkThis.Width = 280; $chkThis.Top = 190  
    $chkThis.Text = "PowerShell CheckBox" 
    $chkThis.Checked = $true   # set a default value 
    $chkThis.TabIndex = 2 
    $form.Controls.Add($chkThis) 
    # Obtain Value with: $chkThis.Checked 
 
 
## Create the OS Image ComboBox 
$lblImage = New-Object System.Windows.Forms.Label; $lblImage.Text = "VM Template:"; $lblImage.Top = 230; $lblImage.Left = 5; $lblImage.Autosize = $true  
    $form.Controls.Add($lblImage)    # Add to Form 
$cbImage1 = New-Object Windows.Forms.ComboBox ; $cbImage1.Top = 230; $cbImage1.Left = 160; $cbImage1.Width = 550 
    Write-Host "Building list of available VM images" (Get-Date) -ForegroundColor Green 
    $ArrayImage = Get-AzureVMImage  # Download a list of VM OS Images from the Azure Portal 
    [void] $cbImage1.BeginUpdate() # This tells the control to not update the display while processing (saves time) 
    $i = 0 ; $iSelect = -1 
    foreach ($element in $ArrayImage) {  
        $thisElement = $i.ToString() +"::" + $element.label 
        [void] $cbImage1.Items.Add($thisElement) 
        if ($element.label -eq "Windows Server 2012 R2 Datacenter, April 2015")  
          {$cbImage1.Text = $thisElement; $iSelect = $i } # Set Default     $cbImage1.Text = $i.ToString() +"::" +$element.label 
        $i ++ 
        } 
    $cbImage1.SelectedIndex = $iSelect  # Set the default SelectedIndex 
    [void] $cbImage1.EndUpdate()  # update the control with all the data that was added 
    $form.Controls.Add($cbImage1) 
    Write-Host "Finished building list of available VM Images" (Get-Date) -ForegroundColor Green 
    # Obtain Value with: $cbImage1.SelectedItem 
    # Obtain index: $cbImage1.SelectedIndex 
    # Obtain Access to entire SELECTED element from original Array with: $ArrayImage[$cbImage1.SelectedIndex].????? 
 
## Finalize Form and Show Dialog 
Write-Host "Show form" (Get-Date)  
$form.Add_Shown( { $form.Activate(); $okButton.Focus() } )  #Activate and Set Focus 
$result = $form.ShowDialog()          ## Show the form, and wait for the response 
 
# Finished with Dialog Box, Now let's see what the user did... 
$Result 
if($result -eq "OK") 
    {   # Copy variables and use them as you desire... 
    $txtHost.Text 
    $locListBox.SelectedItem 
    $chkThis.Checked 
    $cbImage1.SelectedItem 
    Write-Host "VM Image:" $cbImage1.SelectedItem 
    Write-Host $cbImage1.SelectedIndex 
    $ArrayImage[($cbImage1.SelectedIndex)].ImageName 
    $ArrayImage[($cbImage1.SelectedIndex)].Label 
} 
else {Write-Host "Cancel"} 