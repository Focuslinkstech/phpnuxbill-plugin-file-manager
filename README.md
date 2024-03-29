## phpnuxbill plugin file manager
 The File Manager plugin for PHPNuxBill is a powerful tool that enhances the functionality of the PHPNuxBill billing and invoicing system by providing a comprehensive file management solution. This plugin allows users to efficiently organize, store, and manage files and documents associated with their billing operations.  
 
 ## Key Features 
 
 - File Upload and Storage: The plugin enables Admin to upload and store files directly within the PHPNuxBill system. It supports various file types, including documents, images, PDFs, and more.  
 - Folder Organization: Admin can create folders and subfolder to categorize and structure their files. This feature helps maintain a well-organized file system, making it easy to locate and access specific documents.  
 - File Preview and Download: The plugin provides a convenient file preview feature, allowing users to quickly view the contents of supported file types without the need for additional software. Admin can also download files directly from the file manager.  
- The File Manager plugin for PHPNuxBill incorporates robust CSRF (Cross-Site Request Forgery) protection to enhance the security of the application. CSRF protection helps prevent unauthorized and malicious actions performed on behalf of authenticated users, safeguarding sensitive data and maintaining the integrity of the system.  
 
 ## Key CSRF Protection Measures  
 
 - CSRF Token Generation and Inclusion: The plugin generates a unique CSRF token for each user session. This token is embedded in HTML forms and included in AJAX request headers. By associating the CSRF token with the user's session, the plugin ensures that subsequent requests originating from the user's browser are validated for authenticity.  
 
 - CSRF Token Validation: When a form is submitted or an AJAX request is made, the plugin validates the CSRF token sent along with the request. It compares the received token with the one stored in the user's session. If the tokens match, the request is considered legitimate, and the action is executed. In case of a mismatch, the request is rejected as a potential CSRF attack.  
 
 - SameSite Attribute for Cookies: The plugin sets the SameSite attribute for session cookies used in the PHPNuxBill application. By configuring the SameSite attribute to "Strict" or "Lax," the plugin restricts the usage of cookies to same-site requests only. This measure mitigates the risk of CSRF attacks through cookie manipulation.  
 
 - Referrer/Header Validation: The plugin implements additional protection by validating the Referrer or Origin header of incoming requests. It ensures that requests originate from the same domain as the PHPNuxBill application. While this measure provides an extra layer of security, it is important to note that headers can be manipulated, and additional CSRF protection measures are still necessary.  
 
 But its SAD i have stop maintaining this project.


 ## Installation 

 Copy file_manager.php to folder system/plugin/

 Copy ui/file_manager.tpl to folder system/plugin/ui/
