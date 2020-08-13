<?php
if(isset($_POST['submit']))
{

 echo "HHEEELLLO";
        $post_image = $_FILES['image']['name'];   
        print_r ['$post_image'];
	$post_image_temp = $_FILES['image']['tmp_name'];  
	
        echo $post_image;
	echo $post_image_temp;
	move_uploaded_file($post_image_temp, "test/$post_image");



//    $image_name = $_FILES['image']['name'];
//    $image_tmp = $_FILES['image'['tmp_name'];

//    move_uploaded_file($image_tmp, "test/$image_name");

    
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Check file upload</title>
</head>
<body>
<form action="" method="post" enctype="multipart/form-data">

    <label for="post_image">Post Image</label>
    <input type="file" name="image">

<input type="submit" name="submit" value="submit">
</form>
    
</body>
</html>
