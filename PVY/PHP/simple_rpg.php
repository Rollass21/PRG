<html>
 <body>
 <?php
    include("kodpripojenidb.php");
 ?>
  <a href="http://phpcko.tode.cz"><– Zpět</a>
  <form action="postavicka.php" method="post">
   Name: <input type="text" name="name"><br>
   Gender:<br>
	  <input type="radio" name="gender" value = "0" checked> Male<br>
      <input type="radio" name="gender" value = "1"> Female<br>
   Race:<br>
	  <input type="radio" name="race" value = "0" checked> Human<br>
	  <input type="radio" name="race" value = "1"> Orc<br>
	  <input type="radio" name="race" value = "2"> Elf<br>
      <input type="radio" name="race" value = "3"> Dwarf<br>
   Class:<br>
	  <input type="radio" name="class" value = "0" checked> Warrior<br>
	  <input type="radio" name="class" value = "1"> Mage<br>
	  <input type="radio" name="class" value = "2"> Hunter<br>
	  
	  <input type="submit">
  </form>
	 
  <?php

   $HI  = 30;   //HIGH value
   $ME  = 20;   //MEDIUM value
   $LO  = 10;   //LOW value
    
    $race_name = array('Human', 'Orc', 'Elf', 'Dwarf');
    
    switch($_POST['race'])
    {
      //Human
      case 0 :
          $ability = array
          (
          'defence' => $ME,
         'strength' => $ME,
             'luck' => $HI
          );
          $pic = '<img src="https://thumbs.dreamstime.com/z/human-body-anatomy-male-female-4878230.jpg" width="500" height="500">';
          break;
      //Orc
      case 1 :
          $ability = array
          (
          'defence' => $HI,
         'strength' => $HI,
             'luck' => $LO
          );
          $pic = '<img src="https://cdn.shopify.com/s/files/1/0225/1115/products/character-micro-orc-gronk-low-poly-3d-model-4_2000x.jpeg?v=1456744347" width="500" height="500">';
          break;
      //Elf
      case 2 :
          $ability = array
          (
          'defence' => $LO,
         'strength' => $ME,
             'luck' => $LO
          );
          $pic = '<img src="https://pocketmortys.net/images/assets/MortyElfFront.png" width="500" height="500">';
          break;
      //Dwarf
      case 3 :
          $ability = array
          (
          'defence' => $HI,
         'strength' => $ME,
             'luck' => $HI
          );
          $pic = '<img src="https://vignette.wikia.nocookie.net/simpsons/images/d/db/Estonian_Dwarf.png/revision/latest?cb=20111123100845" width="500" height="500">';
          break;
    }
    
    function r($max){
        return rand(0, $max);
    }

    if(empty($_POST['name'])){
        echo 'Zadejte sve jmeno!';
    }
    else {
      echo $pic;
      echo '<br><br>';
      $sql = "INSERT INTO rpg (jmeno, rasa, sila, odolnost, stesti, vznik) 
      VALUES ('".$_POST['name']."','".$race_name[$_POST['race']]."','".r($ability['strength'])."','".r($ability['defence'])."','".r($ability['luck'])."', CURRENT_TIMESTAMP)";
      if($result = mysqli_query($conn, $sql) === TRUE){
          echo '<br>Odeslano na server!<br>';
      }
      else{
          echo "Error: " . $sql . "<br>" . $conn->error;
      }
    }
   
  ?>		
	 
 </body>
</html>
