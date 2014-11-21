#!/usr/bin/perl

##################################################
# Author: http://otroblogdetecnologias.blogspot.com
# freelanceparaguay@hotmail.com
# Version: 1.0
#
# The author is not liable for damages caused by the use Script
#
# Function of the program:
# ======================
# With a given account, get followers from Twitter account
# Save the results to a CSV file called report.csv for further processing
# =======================
# README !!!!
# =======================
# * Before placing running chmod 755 the script.
# * Install dependencies cpan install Net :: Twitter
# * Due to restrictions imposed Twitter, the application sleeps for a period of time
##################################################

##################################################
# Author: http://otroblogdetecnologias.blogspot.com
# freelanceparaguay@hotmail.com
# Version: 1.0
#
# El autor no se hace responsable de los danos ocasionados por el uso del script
#
# Función del programa:
#======================
# Con una cuenta dada, obtiene los seguidores de una cuenta de Twitter
# Guarda los resultados en un archivo .CSV para su posterior procesamiento

#=======================
#ATENCION !!!!
#=======================
# * Antes de correr colocar chmod 755 al script.
# * Instalar dependencias cpan install Net::Twitter
##################################################


use 5.010;
use strict;
use warnings;
use Net::Twitter;
use Scalar::Util 'blessed';
use Data::Dumper;

# Authentication is required:
# First you have to create an app Twitter
# Create consumer keys, consumer secrets, accesss tokens, access tokens secret.
my $nt = Net::Twitter->new(
      traits   => [qw/API::RESTv1_1/],
      consumer_key    => "here put your consumer key",
      consumer_secret => "here put your consumer secret",       
      access_token        => "here put your access token",
      access_token_secret => "here put your access token secret",
);

#name of account to follow
#account without @
my $account  = "your_account";
my $fileReport="report.csv";
my $finish=0;

######### configuration
# -1 is the first page
my $cursor = -1;
my $page=0;
my $timeToSleep=300;

print "----------- I will work a bit while Twitter API REST allows me ------------ \n";        
print "----------- Accounts harvested are in report.csv \n";        
while(! $finish){
    print "----------- I am Working ------------ \n";
    eval {
        my @ids;    
        my $r;
        #this bucle is to read from API REST
        #-------------------------------- PROCESS ----------------------------------------------
        while ($cursor != 0 ) {
            #call API REST
            print "----------- Trying to consume the Twiter API -> \n";            
            $r = $nt->followers({ screen_name => $account, cursor => $cursor });         
            $cursor = $r->{next_cursor};           
            print "----------- Trying to process data obtained from Twiter API -> \n";              
            for (my $i=0; $i < $#{$r->{'users'}}; $i++){
                #write to file and then close it
                print "----------- Writing data obtained from Twiter API -> \n";              
                open(FILE,">>",$fileReport) or die "Can not open file: $fileReport $!";
                print FILE "$r->{'users'}[$i]->{'id'},$r->{'users'}[$i]->{'screen_name'},$r->{'users'}[$i]->{'name'},$r->{'users'}[$i]->{'friends_count'},$r->{'users'}[$i]->{'followers_count'},$r->{'users'}[$i]->{'location'},$r->{'users'}[$i]->{'description'}\n";      
                close(FILE);
             };             
        }; #while
        #--------------------------------- END PROCESS ------------------------------------------
        if($cursor == 0){
            print "----------- Terminated process !! -- \n";
            $finish=1;
            exit(0);
        } #cursor
  }; #eval
  if ( my $err = $@ ) {
      die $@ unless blessed $err && $err->isa('Net::Twitter::Error');
      warn "HTTP Response Code: ", $err->code, "\n",
           "HTTP Message......: ", $err->message, "\n",
           "Twitter error.....: ", $err->error, "\n";
#          -------------------------------------------------------------------------
           print "----------- Waiting ... I will go to sleep one moment \n";
           print "----------- Time to sleep in seconds =  $timeToSleep \n";
           print "----------- LAST CURSOR READ= $cursor \n";                  
           sleep($timeToSleep);
  } #if
 
} #while