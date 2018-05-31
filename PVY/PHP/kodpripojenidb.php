<?php
		$servername = "localhost";
		$username = "placeholder";
		$password = "placeholder";
		$dbname = "placeholder";

		// Create connection
		$conn = mysqli_connect($servername, $username, $password, $dbname);

		// Check connection
		if (!$conn) {
			die("Connection failed: " . mysqli_connect_error());
		}
		echo "Connected successfully";
?>
