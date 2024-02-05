{include file="sections/header.tpl"}
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<style>
    .drag-drop-area {
        border: 2px dashed #ccc;
        padding: 20px;
        text-align: center;
        cursor: pointer;
    }

    .drag-drop-area.drag-over {
        background-color: #f7f7f7;
        border-color: #999;
    }
</style>
<style>
    /* CSS styles for file manager table */
    table {
        width: 100%;
        border-collapse: collapse;
    }

    th,
    td {
        padding: 8px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }

    th {
        background-color: #f2f2f2;
    }

    .directory-icon {
        /* Add CSS styles for directory icon */
    }

    .file-icon {
        /* Add CSS styles for file icon */
    }

    .checkbox-toggle {
        margin-right: 5px;
    }

    .file-actions {
        white-space: nowrap;
    }
</style>
<section class="content-header">
    <h1>Manage Files and Folders</h1>
    <ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> Dashboard</a></li>
        <li class="active">File Manager</li>
    </ol>
</section>

<!-- File Upload Modal -->
<!-- File Upload Modal -->
<div class="modal fade" id="upload">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h4 class="modal-title">Upload File</h4>
            </div>
            <div class="modal-body">
                <form id="file-upload-form" enctype="multipart/form-data" method="post">
                    <div class="form-group">
                        <label for="fileInput">Select File(s):</label>
                        <input type="file" class="form-control-file" id="fileInput" name="files[]" multiple><br>
                        <div id="drag-drop-area" class="drag-drop-area">
                            <p>Drag and drop files here</p>
                        </div>
                    </div>
                    <input type="hidden" name="csrf_token" value="{$csrfToken}">
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default pull-left" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Upload</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="rename">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title">Rename File/Folder</h4>
            </div>
            <div class="modal-body">
                <form id="remaneForm" method="POST" action="{$_url}plugin/file_manager_rename_files_folders">
                    <div class="form-group">
                        <label for="fileInput">Old Name:</label>
                        <input type="text" name="oldName" class="form-control" placeholder="" value="">
                        <label for="fileInput">New Name:</label>
                        <input type="text" name="newName" class="form-control" placeholder="" required>
                        <input type="hidden" name="csrf_token" value="{$csrfToken}">
                        <input type="hidden" name="dir" value="{$directory}/">
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default pull-left" data-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary">Rename</button>
                        </div>
                </form>
            </div>
        </div>
    </div>
    <!-- /.modal-content -->
</div>
<!-- /.modal-dialog -->
</div>
<!-- /.modal -->


<section class="content">
    <div class="row">
        <div class="col">
            <div class="box-footer no-padding">
                <div class="mailbox-controls">
                    <!-- Check all button -->
                    <button type="button" class="btn btn-default btn-sm checkbox-toggle"><i class="fa fa-square"></i>
                        Select all</button>
                    <li class="btn-group">
                        <button type="button" class="btn btn-default btn-sm"><i class="fa fa-trash-o"></i></button>
                        <button type="button" class="btn btn-default btn-sm"><i class="fa fa-reply"></i></button>
                        <button type="button" class="btn btn-default btn-sm"><i class="fa fa-share"></i></button>
                        <button type="button" class="btn btn-default btn-sm" onclick="goBack()"><i
                                class="fa fa-arrow-left"></i></button>
                        <button type="button" class="btn btn-default btn-sm" onclick="goForward()"><i
                                class="fa fa-arrow-right"></i></button>
                    </li>
                    <!-- /.btn-group -->
                    <button type="button" class="btn btn-default btn-sm refresh-button"><i
                            class="fa fa-refresh"></i></button>
                    <div class="pull-right">
                        <button type="button" class="btn btn-default btn-sm" data-toggle="modal"
                            data-target="#upload"><i class="fa fa-upload"></i>
                            Upload File
                        </button>
                        <button type="button" class="btn btn-primary btn-sm" data-toggle="modal"
                            data-target="#create-folder"><i class="fa fa-folder"></i> Create Folder</button>
                    </div>
                    <!-- /.pull-right -->
                </div>
            </div><br>
            <div class="box box-primary">
                <div class="box-header with-border">
                    <ol class="breadcrumb">
                        <li><a href="{$_url}plugin/file_manager"><i class="fa fa-folder"></i> root</a></li>
                        {if $parentDirectoryPath}
                        {foreach $parentDirectoryPath as $directory}
                        <li><i class="fa fa-folder"></i> {$directory}</li>
                        {/foreach}
                        {/if}
                    </ol>
                    <div class="box-tools pull-right">
                        <div class="has-feedback">
                            <input type="text" id="search-input" class="form-control input-sm"
                                placeholder="Search Files">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </div>
                </div>
                <div style="overflow-x:auto;" class="box-body no-padding">
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th><input type="checkbox" id="select-all-checkbox"></th>
                                <th>File Name</th>
                                <th>Type</th>
                                <th>Size</th>
                                <th>Modified Date</th>
                                <th>File Permission</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            {assign var="folders" value=[]}
                            {assign var="files" value=[]}
                            {foreach $fileList as $file}
                            {if $file['type'] eq 'Directory'}
                            {assign var="folders" value=array_merge($folders, [$file])}
                            {else}
                            {assign var="files" value=array_merge($files, [$file])}
                            {/if}
                            {/foreach}
                            {foreach $folders as $index => $file}
                            <tr>
                                <td>
                                    <input type="checkbox">
                                </td>
                                <td>
                                    <a href="{$_url}plugin/file_manager&dir={$directory}/{$file['filename']}">
                                        <span class="directory-icon">{$file['filename']}</span>
                                    </a>
                                </td>
                                <td>{$file['type']}</td>
                                <td>{$file['size']}</td>
                                <td>{$file['date']}</td>
                                <td>{$file['perm']}</td>
                                <td>
                                    <div class="file-actions">
                                        {if $file['type'] neq 'Directory'}
                                        <a href="{$_url}plugin/file_manager_download_file/&file={$directory}/{$index}&action=download&csrf_token={$csrfToken}"
                                            class="btn btn-default btn-xs"><i class="fa fa-download"></i></a>
                                        {/if}
                                        <a href="#" class="btn btn-default btn-xs"><i class="fa fa-eye"></i></a>
                                        <a href="#" class="btn btn-default btn-xs" data-toggle="modal"
                                            data-target="#rename_{$index}"><i class="fa fa-pencil"></i></a>
                                        <a href="#" class="btn btn-default btn-xs"
                                            onclick="confirmDeleteFolder('{$_url}plugin/file_manager_delete_folder/&action=delete_folder&directory={$directory}/{$file['filename']}&csrf_token={$csrfToken}')"><i
                                                class="fa fa-trash"></i></a>
                                    </div>
                                </td>
                            </tr>
                            <!-- Rename Modal -->
                            <div class="modal fade" id="rename_{$index}">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                <span aria-hidden="true">&times;</span>
                                            </button>
                                            <h4 class="modal-title">Rename: {$file['filename']}</h4>
                                        </div>
                                        <div class="modal-body">
                                            <form id="renameForm" method="POST"
                                                action="{$_url}plugin/file_manager_rename_files_folders">
                                                <div class="form-group">
                                                    <label for="fileInput">Old Name:</label>
                                                    <input type="text" name="oldName" class="form-control"
                                                        placeholder="" value="{$file['filename']}" readonly>
                                                    <label for="fileInput">New Name:</label>
                                                    <input type="text" name="newName" class="form-control"
                                                        placeholder="" value="{$file['filename']}" required>
                                                    <input type="hidden" name="csrf_token" value="{$csrfToken}">
                                                    <input type="hidden" name="dir" value="{$directory}/">
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-default pull-left"
                                                            data-dismiss="modal">Cancel</button>
                                                        <button type="submit" class="btn btn-primary">Rename</button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- End Rename Modal -->
                            {/foreach}
                            {foreach $files as $index => $file}
                            <tr>
                                <td>
                                    <input type="checkbox">
                                </td>
                                <td>
                                    <span class="file-icon">{$file['filename']}</span>
                                </td>
                                <td>{$file['type']}</td>
                                <td>{$file['size']}</td>
                                <td>{$file['date']}</td>
                                <td>{$file['perm']}</td>
                                <td>
                                    <div class="file-actions">
                                        <a href="{$_url}plugin/file_manager_download_file/&file={$directory}/{$file['filename']}&action=download&csrf_token={$csrfToken}"
                                            class="btn btn-default btn-xs"><i class="fa fa-download"></i></a>
                                        <a href="#" class="btn btn-default btn-xs"><i class="fa fa-eye"></i></a>
                                        <a href="#" class="btn btn-default btn-xs" data-toggle="modal"
                                            data-target="#renameModal_{$index}"><i class="fa fa-pencil"></i></a>
                                        <a href="#" class="btn btn-default btn-xs"
                                            onclick="confirmDelete('{$_url}plugin/file_manager_delete_file/&file={$directory}/{$file['filename']}&action=delete&csrf_token={$csrfToken}')"><i
                                                class="fa fa-trash"></i></a>
                                    </div>
                                </td>
                            </tr>
                            <div class="modal fade" id="renameModal_{$index}">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                <span aria-labelledby="renameModalLabel_{$index}"
                                                    aria-hidden="true">&times;</span>
                                            </button>
                                            <h4 class="modal-title">Rename: {$file['filename']}</h4>
                                        </div>
                                        <div class="modal-body">
                                            <form id="renameForm" method="POST"
                                                action="{$_url}plugin/file_manager_rename_files_folders">
                                                <div class="form-group">
                                                    <label for="fileInput">Old Name:</label>
                                                    <input type="text" name="oldName" class="form-control"
                                                        placeholder="" value="{$file['filename']}" readonly>
                                                    <label for="fileInput">New Name:</label>
                                                    <input type="text" name="newName" class="form-control"
                                                        placeholder="" value="{$file['filename']}" required>
                                                    <input type="hidden" name="csrf_token" value="{$csrfToken}">
                                                    <input type="hidden" name="dir" value="{$directory}/">
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-default pull-left"
                                                            data-dismiss="modal">Cancel</button>
                                                        <button type="submit" class="btn btn-primary">Rename</button>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            {/foreach}
                        </tbody>
                    </table>
                </div>

                <div class="box-footer clearfix">
                    <div class="">
                        Full Size: <b> {$folderSize}</b> File: <b>{$fileCount}</b> Folder: <b>{$folderCount}</b>
                    </div>
                </div>
            </div>
            <div class="box-footer no-padding">
                <div class="mailbox-controls">
                    <button type="button" class="btn btn-default btn-sm checkbox-toggle"><i class="fa fa-square"></i>
                        Select all</button>

                    <li class="btn-group">
                        <button type="button" class="btn btn-default btn-sm"><i class="fa fa-trash-o"></i></button>
                        <button type="button" class="btn btn-default btn-sm"><i class="fa fa-reply"></i></button>
                        <button type="button" class="btn btn-default btn-sm"><i class="fa fa-share"></i></button>
                        <button type="button" class="btn btn-default btn-sm" onclick="goBack()"><i
                                class="fa fa-arrow-left"></i></button>
                        <button type="button" class="btn btn-default btn-sm" onclick="goForward()"><i
                                class="fa fa-arrow-right"></i></button>
                    </li>
                    <button type="button" class="btn btn-info btn-sm"><i class="fa fa-copy"></i> Copy</button>
                    <button type="button" class="btn btn-warning btn-sm"><i class="fa fa-paste"></i> Move</button>
                    <button type="button" class="btn btn-success btn-sm"><i class="fa fa-file-zip-o"></i> Zip</button>
                    <button type="button" class="btn btn-default btn-sm"><i class="fa fa-file-archive-o"></i>
                        Tar</button>
                    <div class="pull-right">

                        <!-- /.btn-group -->
                    </div>
                    <!-- /.pull-right -->
                </div>
            </div>
        </div>
    </div>
</section>

<div class="modal fade" id="create-folder">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title"><i class="fa fa-folder"></i> Create New Folder</h4>
            </div>
            <div class="modal-body">
                <form id="createFolderForm" method="POST" action="">
                    <div class="form-group">
                        <input type="text" name="newFolderName" class="form-control" placeholder="Enter folder name"
                            required>
                        <input type="hidden" name="csrf_token" value="{$csrfToken}">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default pull-left" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" id="createFolderBtn">Create Folder</button>
                    </div>
                </form </div>
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>


    <script>

        function confirmDelete(deleteUrl) {
            Swal.fire({
                title: "Are you sure?",
                text: "Once deleted, this folder and its contents cannot be recovered!",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                confirmButtonText: "Delete",
                cancelButtonText: "Cancel",
            }).then((result) => {
                if (result.isConfirmed) {
                    fetch(deleteUrl)
                        .then((response) => response.json())
                        .then((data) => {
                            if (data.status === "success") {
                                Swal.fire({
                                    title: "Success",
                                    text: data.message,
                                    icon: "success",
                                }).then(() => {
                                    location.reload();
                                });
                            } else {
                                Swal.fire("Error", data.message, "error");
                            }
                        })
                        .catch((error) => {
                            console.error(error);
                            Swal.fire("Error", "An error occurred while deleting the file.", "error");
                        });
                }
            });
        }


        function confirmDeleteFolder(deleteUrl) {
            Swal.fire({
                title: "Are you sure?",
                text: "Once deleted, this folder and its contents cannot be recovered!",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                confirmButtonText: "Delete",
                cancelButtonText: "Cancel",
            }).then((result) => {
                if (result.isConfirmed) {
                    fetch(deleteUrl)
                        .then((response) => response.json())
                        .then((data) => {
                            if (data.status === "success") {
                                Swal.fire({
                                    title: "Success",
                                    text: data.message,
                                    icon: "success",
                                }).then(() => {
                                    location.reload();
                                });
                            } else {
                                Swal.fire("Error", data.message, "error");
                            }
                        })
                        .catch((error) => {
                            console.error(error);
                            Swal.fire("Error", "An error occurred while deleting the folder.", "error");
                        });
                }
            });
        }

        // Function to go back in history
        function goBack() {
            history.back();
        }

        // Function to go forward in history
        function goForward() {
            history.forward();
        }

        // Handle click event on refresh button to reload the page
        document.addEventListener('DOMContentLoaded', function () {
            var refreshButton = document.querySelector('.refresh-button');
            refreshButton.addEventListener('click', function () {
                // Refresh the page
                location.reload();
            });
        });

        document.addEventListener('DOMContentLoaded', function () {
            $('#createFolderBtn').click(function () {
                var formData = $('#createFolderForm').serialize();

                $.ajax({
                    url: "{$_url}plugin/file_manager_create_folder&dir={$directory}",
                    type: "POST",
                    data: formData,
                    success: function (response) {
                        console.log(response);
                        Swal.fire({
                            icon: "success",
                            title: "Success",
                            text: "Folder created successfully!"
                        }).then(function () {
                            location.reload();
                        });
                    },
                    error: function (xhr, status, error) {
                        console.error(error);
                        if (xhr.status === 409) {
                            Swal.fire({
                                icon: "error",
                                title: "Error",
                                text: "Folder already exists!"
                            });
                        } else {
                            Swal.fire({
                                icon: "error",
                                title: "Error",
                                text: "Failed to create folder. Please try again."
                            });
                        }
                    }
                });
            });
        });
        // Functionality to select/unselect all checkboxes and update the state of "Select All" checkbox
        document.addEventListener('DOMContentLoaded', function () {
            var selectAllButtons = document.querySelectorAll('.checkbox-toggle');
            var selectAllCheckbox = document.getElementById('select-all-checkbox');
            var checkboxes = document.querySelectorAll('tbody input[type="checkbox"]');

            selectAllButtons.forEach(function (button) {
                button.addEventListener('click', function () {
                    var isChecked = this.classList.contains('active');
                    checkboxes.forEach(function (checkbox) {
                        checkbox.checked = !isChecked;
                    });
                    selectAllCheckbox.checked = !isChecked;
                    this.classList.toggle('active');
                });
            });

            selectAllCheckbox.addEventListener('change', function () {
                checkboxes.forEach(function (checkbox) {
                    checkbox.checked = selectAllCheckbox.checked;
                });
                selectAllButtons.forEach(function (button) {
                    button.classList.toggle('active', selectAllCheckbox.checked);
                });
            });

            checkboxes.forEach(function (checkbox) {
                checkbox.addEventListener('change', function () {
                    var allChecked = true;
                    checkboxes.forEach(function (checkbox) {
                        if (!checkbox.checked) {
                            allChecked = false;
                        }
                    });
                    selectAllCheckbox.checked = allChecked;
                    selectAllButtons.forEach(function (button) {
                        button.classListtoggle('active', allChecked);
                    });
                });
            });
        });

        // Functionality to filter table rows based on user input
        document.addEventListener('DOMContentLoaded', function () {
            var searchInput = document.getElementById('search-input');
            var tableRows = document.querySelectorAll('tbody tr');

            searchInput.addEventListener('input', function () {
                var searchText = this.value.toLowerCase();

                tableRows.forEach(function (row) {
                    var rowData = row.textContent.toLowerCase();

                    if (rowData.includes(searchText)) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
        });

        document.addEventListener('DOMContentLoaded', function () {
            var fileUploadForm = document.getElementById('file-upload-form');

            fileUploadForm.addEventListener('submit', function (event) {
                event.preventDefault();

                var formData = new FormData(fileUploadForm);

                // Send AJAX request
                $.ajax({
                    url: "{$_url}plugin/file_manager_upload_files&dir={$directory}",
                    type: "POST",
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function (response) {
                        console.log(response);
                        Swal.fire({
                            icon: "success",
                            title: "Success",
                            text: "File uploaded successfully!"
                        }).then(function () {
                            location.reload();
                        });
                    },
                    error: function (xhr, status, error) {
                        console.error(error);
                        Swal.fire({
                            icon: "error",
                            title: "Error",
                            text: "Failed to upload file. Please try again."
                        });
                    }
                });
            });
        });
        // Handle drag and drop events
        var dragDropArea = document.getElementById('drag-drop-area');

        dragDropArea.addEventListener('dragover', function (event) {
            event.preventDefault();
            dragDropArea.classList.add('drag-over');
        });

        dragDropArea.addEventListener('dragleave', function (event) {
            event.preventDefault();
            dragDropArea.classList.remove('drag-over');
        });

        dragDropArea.addEventListener('drop', function (event) {
            event.preventDefault();
            dragDropArea.classList.remove('drag-over');

            var files = event.dataTransfer.files;
            var fileInput = document.getElementById('fileInput');
            fileInput.files = files;
        });

        // Prevent default behavior for drag events
        document.addEventListener('dragover', function (event) {
            event.preventDefault();
        });

        document.addEventListener('drop', function (event) {
            event.preventDefault();
        });
    </script>
    <script>
        window.addEventListener('DOMContentLoaded', function () {
            var portalLink = "https://github.com/focuslinkstech";
            $('#version').html('File Manager Plugin by: <a href="' + portalLink + '">Focuslinks Tech</a>');
        });
    </script>
    {include file="sections/footer.tpl"}