<html>
<?php

include_once('settings.php');
include_once('lib.php');

$userID = $_GET['userID'];

$ok=0;

if(is_dir("subjects/$userID/")) {
    $ok=0;
    echo "Subject folder already exists.<br>";
}
else
{
    $ok=1;
    system("mkdir subjects/$userID/",$ret);
    if($ret==0)
    {               
        system("chmod 777 subjects/$userID/",$ret);
        if($ret!=0)
            die("There was a disk error. Please email ".$pagetexts['contact_email']);
    }
}


?>

<h2>Please direct your attention to the other monitor.</h2>


</html>
