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

if (empty($_ENV['AWS_ACCESS_KEY_ID']) || empty($_ENV['AWS_SECRET_ACCESS_KEY'])) {
  die("Do not seem to have AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables available.");
}

$json = @file_get_contents($INFILE);
if (!$json) {
  die("Appear to be missing {$INFILE}");
}

$find = array('%AWS_ACCESS_KEY%','%AWS_SECRET_KEY%');
$replace = array($_ENV['AWS_ACCESS_KEY_ID'], $_ENV['AWS_SECRET_ACCESS_KEY']);
$count = 0;

$json = str_replace($find, $replace, $json, $count);

$fh = fopen($OUTFILE, "w");
if (!$fh) {
  die("Error opening outfile {$OUTFILE}");
}
fwrite($fh, $json);
fclose($fh);

fprintf(stderr, "Replaced %d tags and wrote to %s\n", $count, $OUTFILE);


 
