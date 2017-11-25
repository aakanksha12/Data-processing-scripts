##########################This pipeline is created by Akanksha Pandey at University of Florida on 10/20/17#################
# It requires an input query name and genome name text files on the command line #
# Processes the files generated by extract_seq.pl and creates concatenated fasta files and alignment of those fasta files #



#!/usr/local/bin/perl
#use strict;
#use warnings;


my $dir = "<path to working directory>";
my $dir1 = "<path to extract seq directory>";
my $sep = "\t";

my ($input_query,$input_db) = @ARGV;
print "The arguments passed are :\n";
foreach my $temp(@ARGV) #prints arguments
{
print"$temp\n";
}

my @query_prefix =();
my @db_prefix = ();
open(my $fh1,"<","$dir/$input_query") or die "Can't open $input_query\n"; #creates query array from file provided
{
print "The input queries are \n";
while(my $line = <$fh1>)
{
chomp($line);
push(@query_prefix,$line);
print"$line\n";
}
}

open(my $fh2,"<","$dir/$input_db") or die "Can't open $input_db\n"; #creates db array from file provided
{
print "The input genomes are\n";
while(my $line = <$fh2>)
{
chomp($line);
push(@db_prefix,$line);
print"$line\n";
}
}



foreach my $temp(@query_prefix)
{
	my $out_file = $temp . ".out". ".txt"; # Concatenated fasta files for all the taxa for the given loci
	my $align_out = $temp . "fasta"; # output alignment file generated using mafft
foreach my $temp1(@db_prefix)
{
	my $file_name = $temp1 . ".$temp" . ".extract" . ".fasta"; # File generated using extract.pl
	my $log_out = "log" . ".txt";
	open(my $fh3,">>","$dir/$log_out") or die "Couldn't open $log_out\n";
	{
		if(-s "$dir1/seq_v4/$file_name") #checks whether extracted sequence file is present for that query
		{ 
			print $fh3 "Query :$temp \t Genome: $temp1 \n";
			open(my $fh4,"<","$dir1/$file_name") or die "Couldn't open $file_name\n"; # open the extracted query from genome generated using extract.pl
		{
			open(my $fh5,">>","$dir/$out_file")or die "Couldn't open $out_file\n"; # Writes fasta file for different taxa in one text file 
		{
			while (my $line = <$fh4>)
				{
					chomp($line);
					print $fh5 "$line\n";
				}
		}
		}
		}
	else
		{
		print $fh3 "$file_name is not found\n";
		next;
		}
	}
}
	
system("mafft $out_file > $align_out"); #Calls mafft for alignment on concatenated fasta file 
	
	my @dat = ReadInFASTA($align_out);
	my @taxon = GetSeqName(@dat);
	my @seqdata = GetSeqDat(@dat);
	my $align_out_file = $temp . ".align". ".fasta";
	open(my $fh6,">>","$dir/$align_out_file"); #rewrites alignment file to remove \n within the sequence
	{
		for(my $i=0;$i <=$#taxon; $i++)
		{
		print"$taxon[$i]\n";
		print $fh6 ">$temp$taxon[$i]\n$seqdata[$i]\n";
		}
	}
	
}
		
sub ReadInFASTA {
    my $infile = shift;
    my @line;
    my $i = -1;
    my @result = ();
    my @seqName = ();
    my @seqDat = ();

    open (INFILE,"$dir/$infile") || die "Can't open $infile\n";

    while (<INFILE>) {
        chomp;
        if (/^>/) {  # name line in fasta format
            $i++;
            s/^>\s*//; s/^\s+//; s/\s+$//;
            $seqName[$i] = $_;
            $seqDat[$i] = "";
        } else {
            s/^\s+//; s/\s+$//;
	    s/\s+//g;                  # get rid of any spaces
            next if (/^$/);            # skip empty line
            s/[uU]/T/g;                  # change U to T
            $seqDat[$i] = $seqDat[$i] . uc($_);
        }

	# checking no occurence of internal separator $sep.
	die ("ERROR: \"$sep\" is an internal separator.  Line $. of " .
	     "the input FASTA file contains this charcter. Make sure this " . 
	     "separator character is not used in your data file or modify " .
	     "variable \$sep in this script to some other character.\n")
	    if (/$sep/);

    }
    close(INFILE);

    foreach my $i (0..$#seqName) {
	$result[$i] = $seqName[$i] . $sep . $seqDat[$i];
    }
    return (@result);
}
sub GetSeqDat {
    my @data = @_;
    my @line;
    my @result = ();

    foreach my $i (@data) {
	@line = split (/$sep/, $i);
	push @result, $line[1];
    }

    return (@result)
}

sub GetSeqName {
    my @data = @_;
    my @line;
    my @result = ();

    foreach my $i (@data) {
	@line = split (/$sep/, $i);
	push @result, $line[0];
    }
    return (@result)
}
