<?php
session_start();

register_menu(" File Manager", true, "file_manager", 'AFTER_SETTINGS', 'ion ion-folder');

function file_manager()
{
    global $ui, $routes;
    _admin();
    $ui->assign('_title', 'File Manager');
    $ui->assign('_system_menu', '');
    $admin = Admin::_info();
    $ui->assign('_admin', $admin);
    $action = $routes['1'];

    if ($admin['user_type'] != 'Admin' && $admin['user_type'] != 'Sales') {
        r2(U . "dashboard", 'e', $_L['Do_Not_Access']);
    }

    // Get the directory path from the URL parameter
    $directory = isset($_GET['dir']) ? $_GET['dir'] : '';

    // Split the directory path into individual directories
    $directoryPath = explode('/', $directory);
    $directoryPath = array_filter($directoryPath);

    // Prepare an array to store the breadcrumb items
    $breadcrumb = [];

    // Generate breadcrumb items for each directory in the path
    $path = '';
    foreach ($directoryPath as $dir) {
        $path .= '/' . $dir;
        $breadcrumb[] = $dir;
    }

    $ui->assign('parentDirectoryPath', $breadcrumb);
    $ui->assign('currentDirectory', end($directoryPath)); // Pass the current directory to the template

    // Retrieve the list of files in the directory
    $fileList = glob($directory . '/*');

    if ($fileList === false) {
        // Error occurred while retrieving the file list
        _LOG('Error retrieving file list for directory: ' . $directory);
        $fileList = []; // Set an empty array to display no files
    }

    $files = [];

    // Iterate through the files and extract relevant information
    foreach ($fileList as $file) {
        $fileName = basename($file);
        $fileType = is_dir($file) ? 'Directory' : pathinfo($file, PATHINFO_EXTENSION);

        if (is_dir($file)) {
            $fileSize = 'Directory';
        } else {
            $fileSize = file_manager_filesize_format(filesize($file));
        }

        $fileDate = date('Y-m-d h:i:s A', filemtime($file));
        $filePermission = substr(sprintf('%o', fileperms($file)), -4);
        $files[] = [
            'filename' => $fileName,
            'type' => $fileType,
            'size' => $fileSize,
            'date' => $fileDate,
            'perm' => $filePermission,
        ];
    }

    $ui->assign('fileList', $files); // Pass the file list to the template
    $ui->assign('directory', $directory);

    // Calculate folder size, file count, and folder count
    $folderSize = 0;
    $fileCount = 0;
    $folderCount = 0;

    foreach ($files as $file) {
        if ($file['type'] === 'Directory') {
            $folderCount++;
        } else {
            $fileCount++;
            if ($file['size'] !== 'Directory') {
                $folderSize += filesize($directory . '/' . $file['filename']);
            }
        }
    }

    $csrfToken = file_manager_generate_csrf_token();
    $ui->assign('csrfToken', $csrfToken);
    $ui->assign('folderSize', file_manager_filesize_format($folderSize));
    $ui->assign('fileCount', $fileCount);
    $ui->assign('folderCount', $folderCount);

    $ui->display('file_manager.tpl');
}

// Function to format file size
function file_manager_filesize_format($filesize) {
    $size = $filesize;

    $units = array('B', 'KB', 'MB', 'GB', 'TB');

    $unitIndex = 0;
    while ($size >= 1024 && $unitIndex < count($units) - 1) {
        $size /= 1024;
        $unitIndex++;
    }

    return round($size, 2) . ' ' . $units[$unitIndex];
}

function file_manager_create_folder()
{
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Validate CSRF token
        $csrfToken = isset($_POST['csrf_token']) ? $_POST['csrf_token'] : '';
        if (!file_manager_validate_csrf_token($csrfToken)) {
            http_response_code(403); // Set appropriate HTTP response code for forbidden
            echo 'Invalid CSRF token';
            return;
        }

        $newFolderName = $_POST['newFolderName']; // Get the new folder name from the form input
        $currentDirectory = $_GET['dir']; // Get the current directory from the URL parameter

        $newFolderPath = $currentDirectory . '/' . $newFolderName; // Create the new folder path
        if (!file_exists($newFolderPath)) {
            if (mkdir($newFolderPath, 0777)) {
                echo 'Folder created successfully!';
            } else {
                http_response_code(500); // Set appropriate HTTP response code for server error
                echo 'Invalid CSRF token';
            }
        } else {
            http_response_code(409); // Set appropriate HTTP response code for conflict
            echo 'Folder already exists!';
        }
    }
}

// Generate CSRF token
function file_manager_generate_csrf_token()
{
    $tokenExpiration = time() + 300; // Token expiry set to 5 minutes
    if (!isset($_SESSION['csrf_token']) || $_SESSION['csrf_token_expiration'] < time()) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        $_SESSION['csrf_token_expiration'] = $tokenExpiration;
    }
    return $_SESSION['csrf_token'];
}

// Validate CSRF token
function file_manager_validate_csrf_token($token)
{
    if (!isset($_SESSION['csrf_token']) || $_SESSION['csrf_token'] !== $token || $_SESSION['csrf_token_expiration'] < time()) {
        // Invalid or expired CSRF token
        return false;
    }
    return true;
}


function file_manager_upload_files()
{
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Validate CSRF token
        $csrfToken = isset($_POST['csrf_token']) ? $_POST['csrf_token'] : '';
        if (!file_manager_validate_csrf_token($csrfToken)) {
            // Invalid CSRF token, handle the error
            echo json_encode(['error' => 'Invalid CSRF token']);
            return;
        }

        // Retrieve the current directory from the URL parameter
        $currentDirectory = isset($_GET['dir']) ? trim($_GET['dir'], '/') : '';

        // Specify the upload directory and create it if it doesn't exist
        $uploadDirectory = '/' . $currentDirectory;

        if (!is_dir($uploadDirectory)) {
            mkdir($uploadDirectory, 0777, true);
        }

        $response = array(); // Initialize response array

        // Iterate through each uploaded file and handle different upload errors
        foreach ($_FILES['files']['tmp_name'] as $key => $tmpName) {
            $fileError = $_FILES['files']['error'][$key];

            if ($fileError === UPLOAD_ERR_OK) {
                // Move the uploaded file to the destination directory if there are no errors
                $fileName = $_FILES['files']['name'][$key];
                $destination = $uploadDirectory . '/' . $fileName;

                if (move_uploaded_file($tmpName, $destination)) {
                    $response[] = "File uploaded successfully: $fileName";
                } else {
                    $response[] = "Failed to move file: $fileName";
                }
            } else {
                // Add appropriate error messages to the response array for different upload errors
                if ($fileError === UPLOAD_ERR_INI_SIZE) {
                    $response[] = "The uploaded file exceeds the upload_max_filesize directive in php.ini";
                } elseif ($fileError === UPLOAD_ERR_FORM_SIZE) {
                    $response[] = "The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form";
                } elseif ($fileError === UPLOAD_ERR_PARTIAL) {
                    $response[] = "The uploaded file was only partially uploaded";
                } elseif ($fileError === UPLOAD_ERR_NO_FILE) {
                    $response[] = "No file was uploaded";
                } elseif ($fileError === UPLOAD_ERR_NO_TMP_DIR) {
                    $response[] = "Missing temporary folder";
                } elseif ($fileError === UPLOAD_ERR_CANT_WRITE) {
                    $response[] = "Failed to write file to disk";
                } elseif ($fileError === UPLOAD_ERR_EXTENSION) {
                    $response[] = "A PHP extension stopped the file upload";
                } else {
                    $response[] = "Unknown upload error";
                }
            }
        }

        // Return the response as JSON
        echo json_encode($response);
    }
}

// Process file download
function file_manager_download_file()
{
    if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'download') {
        // Validate CSRF token
        $csrfToken = isset($_GET['csrf_token']) ? $_GET['csrf_token'] : '';
        if (!file_manager_validate_csrf_token($csrfToken)) {
            // Invalid CSRF token, handle the error
            echo 'Invalid CSRF token';
            return;
        }

        // Retrieve the file path from the URL parameter
        $filePath = isset($_GET['file']) ? $_GET['file'] : '';

        // Validate the file path or perform any necessary security checks

        // Set the appropriate headers for file download
        header('Content-Description: File Transfer');
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . basename($filePath) . '"');
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize($filePath));
        readfile($filePath);
        exit;
    }
}

function file_manager_delete_file()
{
    if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'delete') {
        // Validate CSRF token
        $csrfToken = isset($_GET['csrf_token']) ? $_GET['csrf_token'] : '';
        if (!file_manager_validate_csrf_token($csrfToken)) {
            // Invalid CSRF token, handle the error
            $response = ['status' => 'error', 'message' => 'Invalid CSRF token'];
            echo json_encode($response);
            return;
        }
        // Retrieve the file path from the URL parameter
        $filePath = isset($_GET['file']) ? $_GET['file'] : '';

        // Validate the file path or perform any necessary security checks

        // Delete the file
        if (file_exists($filePath)) {
            unlink($filePath);
            $response = ['status' => 'success', 'message' => 'File deleted successfully!'];
            echo json_encode($response);
        } else {
            $response = ['status' => 'error', 'message' => 'File does not exist!'];
            echo json_encode($response);
        }

        exit;
    }
}

function file_manager_delete_folder()
{
    if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['action']) && $_GET['action'] === 'delete_folder') {
        // Validate CSRF token
        $csrfToken = isset($_GET['csrf_token']) ? $_GET['csrf_token'] : '';
        if (!file_manager_validate_csrf_token($csrfToken)) {
            // Invalid CSRF token, handle the error
            $response = ['status' => 'error', 'message' => 'Invalid CSRF token'];
            echo json_encode($response);
            return;
        }

        $folderPath = isset($_GET['directory']) ? $_GET['directory'] : '';
        if (is_dir($folderPath)) {
            $files = scandir($folderPath);
            foreach ($files as $file) {
                if ($file != "." && $file != "..") {
                    $filePath = $folderPath . DIRECTORY_SEPARATOR . $file;
                    if (is_dir($filePath)) {
                        file_manager_delete_folder($filePath);
                    } else {
                        unlink($filePath);
                    }
                }
            }
            rmdir($folderPath);
            // Optionally, we can also perform additional actions after deleting the folder
            // For example, updating the file list or displaying a success message

            $response = ['status' => 'success', 'message' => 'Folder deleted successfully!'];
            echo json_encode($response);
        } else {
            $response = ['status' => 'error', 'message' => 'Folder does not exist!'];
            echo json_encode($response);
        }

        exit;
    }
}

function file_manager_rename_files_folders()
{
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['dir']) && isset($_POST['oldName']) && isset($_POST['newName'])) {
        // Perform any necessary validation or checks here

        // Validate CSRF token
        $csrfToken = isset($_POST['csrf_token']) ? $_POST['csrf_token'] : '';
        if (!file_manager_validate_csrf_token($csrfToken)) {
            // Invalid CSRF token, handle the error
            $response = ['status' => 'error', 'message' => 'Invalid CSRF token'];
            echo json_encode($response);
            return;
        }

        // Get the old and new names from the request
        $oldName = $_POST['oldName'];
        $newName = $_POST['newName'];
        $dir = $_POST['dir'];

        $oldPath = $dir . $oldName;
        $newPath = $dir . $newName;

        if (file_exists($oldPath)) {
            // Perform the renaming logic
            if (rename($oldPath, $newPath)) {
                // Renaming successful
                $response = ['status' => 'success', 'message' => 'Item renamed successfully'];
                echo json_encode($response);
                return;
            } else {
                // Error occurred while renaming
                $response = ['status' => 'error', 'message' => 'An error occurred while renaming the item'];
                echo json_encode($response);
                return;
            }
        } else {
            // File or folder not found
            $response = ['status' => 'error', 'message' => 'File or folder not found'];
            echo json_encode($response);
            return;
        }
    }
}
