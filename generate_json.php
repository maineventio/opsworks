<?php

/**
 * generate_json.php
 *
 * To guard against commiting any AWS keys to GitHub (once burned...) this script parses cloudformation.json
 * and replaces instances of %AWS_ACCESS_KEY% and %AWS_SECRET_KEY% with values from the environment variables
 * AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
 *
 * For help configuring the AWS environment variables, see http://docs.aws.amazon.com/cli/latest/topic/config-vars.html
 * and http://docs.aws.amazon.com/cli/latest/reference/configure/index.html
 */

$INFILE = 'cloudformation.json';
$OUTFILE = '../cloudformation-private.json';

if (!file_exists('.env.php')) {
  die("You need to have a .env.php file, check out .env.php.sample\n");
}
require('.env.php');
$required = array(
  'aws_access_key','aws_secret_key','elasticsearch_host','vpc_id','vpc_subnet_id','ssh_keyname','sqs_name','sqs_region'
);
$replace = array();
foreach ($required as $key) {
  if (empty($opt[$key])) {
    error_log("Missing required .env.php key '{{$key}}'\n");
    $problem = true;
  }
  $replace[] = $opt[$key];
}
if ($problem) {
  exit;
}

$json = @file_get_contents($INFILE);
if (!$json) {
  die("Appear to be missing {$INFILE}\n");
}

$count = 0;
$json = str_replace($required, $replace, $json, $count);

$fh = fopen($OUTFILE, "w");
if (!$fh) {
  die("Error opening outfile {$OUTFILE}\n");
}
fwrite($fh, $json);
fclose($fh);

error_log("Replaced {{$count}} tags and wrote to {{$OUTFILE}}\n");


 
