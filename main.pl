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
print_filepart();
process_filepart();
print $q->end_html;



sub print_filepart{
	print $q->start_form;
	print $q->filefield(-name=>'uploaded_file',
                            -default=>'starting value',
                            -size=>50,
                            -maxlength=>80),
          $q->submit(-name=>'check_file_button',
                    -value=>'check file for viruses');
	print $q->end_form;
	print $q->hr;
}
####Processing part#####
sub process_filepart{	
	if($q->param('check_file_button')){
		my $lightweight_fh  = $q->upload('uploaded_file');
		if (defined $lightweight_fh) {
   		 	my $io_handle = $lightweight_fh->handle;
   		 	
 	   		print $q->h3('processed file');
			print $q->param('uploaded_file'), $q->p;
			my $bytesread;
   		 	my $buffer;
 	   		#########checking for viruses
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
   			unlink "/tmp/$tempfile_name";   		
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
