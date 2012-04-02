#!/usr/bin/perl
use strict;

use CGI ;
# use XML::Simple;
# use YAML;

my $q = CGI->new;
print $q->header,
	$q->start_html("Conver XML to YAML");
print_textpart();
print_filepart();
process_textpart();
process_filepart();
print $q->end_html;

sub print_textpart{
	print $q->start_form;
	print $q->h1("TEXT");
	print $q->textarea(-name=>'textarea_input',
		-rows=>10,
		-columns=>50);

	print $q->p,$q->defaults;
	print $q->submit(-name=>'text_button',
                         -value=>'convert');
	print $q->end_form;
	print $q->hr;
}

sub print_filepart{
	print $q->start_form;
	print $q->h1("FILE");
	print $q->filefield(-name=>'uploaded_file',
                            -default=>'starting value',
                            -size=>50,
                            -maxlength=>80);
	print $q->submit(-name=>'file_button',
                    -value=>'process file');
	print $q->end_form;
	print $q->hr;
}
sub process_textpart {	
	if($q->param('text_button')){
		print $q->param('textarea_input');
		print $q->hr;
		# print YAML::Dump(XML::Simple::XMLin($q->param("textarea_input")));
	}
}

sub process_filepart{	
	if($q->param('file_button')){
		

		my $lightweight_fh  = $q->upload('uploaded_file');

		if (defined $lightweight_fh) {
  		  # Upgrade the handle to one compatible with IO::Handle:
   		 	my $io_handle = $lightweight_fh->handle;
   		 	my $bytesread;
   		 	my $buffer;
   		 	my $i = 0;
   		 	my $file_as_string = undef;
    		while ($bytesread = $io_handle->read($buffer,1024)) {
    			$file_as_string.=$buffer;
 	   		}
 	   		print $q->h1('processed file');
			print $q->param('uploaded_file'), $q->p;
 	   		# print YAML::Dump(XML::Simple::XMLin($file_as_string));
 	   		print $file_as_string;
  		}
  		else{
  			print  "file error 1";
  			die "file error 1";
  		}

		
	}
}

