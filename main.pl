#!/usr/bin/perl
use strict;

use CGI ;
use IO::Handle;
use XML::Simple;
use YAML;

my $tempfile_name = 'tempfile_for_aaa_to_lptool.tmp';



my $q = CGI->new;
print $q->header,
	$q->start_html('Convert XML to YAML');
print $q->h1({-align=>"left"},'Convert XML to YAML');
# print $q->p,$q->defaults;	#why it doesn't work??
print_textpart();
print_filepart();
process_textpart();
process_filepart();
print $q->end_html;



sub print_textpart{
	print $q->start_form;
	print $q->h3('TEXT');
	print $q->textarea(-name=>'textarea_input',
		-rows=>5,
		-columns=>25);

	print $q->p,$q->submit(-name=>'text_button',
                         -value=>'convert');
	print $q->end_form;
	print $q->hr;
}
sub print_filepart{
	print $q->start_form;
	print $q->h3("FILE");
	print $q->filefield(-name=>'uploaded_file',
                            -default=>'starting value',
                            -size=>50,
                            -maxlength=>80),
          $q->submit(-name=>'convert_file_button',
                    -value=>'convert xml file to YAML'),
          $q->submit(-name=>'check_file_button',
                    -value=>'check file for viruses');
	print $q->end_form;
	print $q->hr;
}
####Processing part#####
sub process_textpart {	
	if($q->param('text_button')){
		print $q->h3('processed text');
		# print $q->param('textarea_input');
		# print YAML::Dump(XML::Simple::XMLin($q->param("textarea_input")));
		process_xml($q->param("textarea_input"))
	}	
}

sub process_filepart{	
	if($q->param('convert_file_button')||$q->param('check_file_button')){
		my $lightweight_fh  = $q->upload('uploaded_file');

		if (defined $lightweight_fh) {
   		 	my $io_handle = $lightweight_fh->handle;
   		 	
 	   		print $q->h3('processed file');
			print $q->param('uploaded_file'), $q->p;
			my $bytesread;
   		 	my $buffer;
			if($q->param('convert_file_button')){
				my $file_as_string = undef;
    			while ($bytesread = $io_handle->read($buffer,1024)) {
    				$file_as_string.=$buffer;
 	   			}
			 	process_xml($file_as_string);
 	   		}
 	   		else{#########checking for viruses
   		 		my $suc = open TEMPFILE, ">/tmp/$tempfile_name";
   		 		unless($suc){
   		 			print  "file error 2:cant create tmp";
  					die "file error 2";
   		 		}
    			while ($bytesread = $io_handle->read($buffer,1024)) {
    				print TEMPFILE $buffer;
 	   			}
 	   			my $xml_out = `/home/spa/PE/lptool /tmp/$tempfile_name`;
 	   			# print "<quote>","$xml_out","</quote>";
 	   			my $filename = $q->param('uploaded_file');
 	   			$xml_out =~ s/$tempfile_name/$filename/;
 	   			process_xml($xml_out);
 	   			# print $q->h2("$xml_out");
 	   			close TEMPFILE;
 	   			unlink "/tmp/$tempfile_name"
 	   		}
 	   		return;
  		}
  		print  "file error 1";
  		die "file error 1";
  		
	}
}
sub process_xml{
	my ($xml_str) = @_;
	$xml_str = "<opt>".$xml_str."</opt>"; #unuseful tag for goog XML::Simple working
	my @out_as_array = split /\n/,(YAML::Dump(XML::Simple::XMLin($xml_str))); 	   	
 	foreach (@out_as_array){
   		print "$_";
 	   	print $q->pre;	#not so good
 	}
	print $q->hr;
}
