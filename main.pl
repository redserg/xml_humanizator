#!/usr/bin/perl
use strict;

use CGI ;
use IO::Handle;
use XML::Simple;
use YAML;


my $tempfile_name = 'tempfile_for_aaa_to_lptool.tmp';
my $tempfile_path_and_name = "/tmp/$tempfile_name";

my $lptool_path = '/home/spa/PE/lptool';
my $lptool_run_string = "$lptool_path  $tempfile_path_and_name";

my $temp_directory_name = '/tmp/XmlResults';
my $malscaner_path = '/home/spa/malscaner/malscaner';
my $malscaner_run_string = "cd $temp_directory_name && $malscaner_path $tempfile_path_and_name";
my $res_file_name = "res-file.xml";
my $res_total_name = "res_total.xml";



my $q = CGI->new;
print $q->header,
	$q->start_html('cheking files');
print_body();
processing();
print $q->end_html;



sub print_body{
	print $q->start_form;
	print $q->filefield(-name=>'uploaded_file',
                            -default=>'starting value',
                            -size=>50,
                            -maxlength=>80),
    				$q->submit(-name=>'lptool_button',
                    -value=>'lptool'),
                    $q->submit(-name=>'malscaner_button',
                    -value=>'malscaner')
                    ;
	print $q->end_form;
	print $q->hr;
}
####Processing part#####
sub processing{	
	if($q->param('lptool_button')||$q->param('malscaner_button')){
		my $lightweight_fh  = $q->upload('uploaded_file');
		if (defined $lightweight_fh) {		#openning loading file and creating tmpfile
   		 	my $io_handle = $lightweight_fh->handle;
   		 	
 	   		print $q->h3('processed file');
			print $q->param('uploaded_file'), $q->p;
			my $bytesread;
   		 	my $buffer;
 	   		my $suc = open TEMPFILE, ">$tempfile_path_and_name";
	 		unless($suc){
	 			print  "file error 2:cant create tmp";
				die "file error 2";
	 		}
			while ($bytesread = $io_handle->read($buffer,1024)) {
				print TEMPFILE $buffer;
   			}
   			if($q->param('lptool_button')){
	   			my $std_out = `$lptool_run_string`;
	   			# print "<quote>","$std_out","</quote>";
	   			my $filename = $q->param('uploaded_file');
	   			$std_out =~ s/$tempfile_name/$filename/; #заменяем имя файла на настоящее, надо переписать

	   			process_xml($std_out);
	   			# print $q->h2("$xml_out");
	   		}
	   		elsif($q->param('malscaner_button')){
	   			

	   			system "mkdir /tmp/XmlResults";
	   			system "$malscaner_run_string >/dev/null";

	   			if (!open TOTAL_FILE,"<$temp_directory_name/XmlResults/$res_total_name"){
	   				print "file error 4";
	   				die "file error 4";
	   			}
	   			my $file_as_str = undef;
	   			while(<TOTAL_FILE>){
	   				$file_as_str.=$_;
	   			}
	   			print_long_string($file_as_str);

	   			print $q->hr;

	   			print_long_string (YAML::Dump(XML::Simple::XMLin("$temp_directory_name/XmlResults/$res_file_name")));
	   			
	   			system "rm -r /tmp/XmlResults";
	   			



	   			close TOTAL_FILE;
	   			#unlink rm-r
	   		}
	   		else{
	   			print "unreacheble error 3";
	   			die "unreacheble error 3";
	   		}



   			close TEMPFILE;
   			unlink "$tempfile_path_and_name";   		
 	   		return;
  		}
  		else{	
	  		print  "file error 1";
  			die "file error 1";
  		}


	}
}
sub process_xml{
	my ($xml_str) = @_;
	$xml_str = "<opt>".$xml_str."</opt>"; #unuseful tag for goog XML::Simple working
	print_long_string (YAML::Dump(XML::Simple::XMLin($xml_str))); 	   	
 	
}
sub print_long_string{
	my ($long_str) = @_;
	my @out_as_array = split /\n/, $long_str;
	foreach (@out_as_array){
   		print "$_";
 	   	print $q->pre;	#not so good
 	}
	print $q->hr;
}
