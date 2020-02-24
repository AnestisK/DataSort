use strict;
use warnings;

# Use the Perl DBI module to perform mysql style statements on CSV files
use DBI;

# setup the database environment
my $dbh = DBI->connect ("dbi:CSV:", undef, undef, {
  RaiseError  => 1,
  PrintError  => 1,

  f_dir       => ".",
  f_ext       => ".csv/r",
  f_schema    => undef,

  csv_null    => 1,
  csv_auto_diag       => 1,
  });

# Function to go through an array and print each entry ona sepearte line
# with a numerical identifier

sub print_list {

  # Seperate the arguments into an array for the choices and the prompt for the user
      
  my @list = splice (@_, 0, -1);
  my $prompt = $_[-1];
  my $x = 1;

  # Print the list of choices

  foreach (@list) {
    print "$x: $_";

    # Attempt to prettify a little bit by having two columns

    if (not $x % 2){
      print "\n";
    }
    else {
      print("\t\t\t");
    }
    $x++;
  }
  print "\n";

  # Ask the user to make a choice

  print $prompt;

  # Process choice by converting to number

  my $ch = <>;
  chomp $ch;
  my $choice = int($ch);

  # Check if the selection is a valid filename.  If not set choice to an invalid
  # number.  If choice is valid, set the filename.
  
  if ($choice <= 0) {
    $choice = @list+100;
  }

  # Return the choice result

  return $choice;
}

# get list of CSV files in local directory

opendir(DIR, ".");
my @files = grep(/\.csv$/,readdir(DIR));
closedir(DIR);

# Create filename variable

my $fh;

# do this loop while filename is undefined

do {
  my $prompt = "Please select the file you wish to input data from: ";
   
  my $choice = print_list(@files, $prompt);

  if ($files[$choice-1]) {
    $fh = $files[$choice-1];
  }
} while (!$fh);


# Read in the headers and turn it into an array

my $header = `head -n 1 $fh`;
chomp $header;
my @cols = split (/,/,$header);
my @sort;
my $col_choice = @cols + 100;
my $quit = "Finish Selecting Columns";
push(@cols, $quit);

while ($cols[$col_choice-1] ne $quit) {
  my $prompt = "Please select the columns to sort on: ";

  # print list and ask user to make a choice

  $col_choice = print_list(@cols, $prompt);
  
  if ($col_choice != scalar(@cols)) {
    push(@sort, $cols[$col_choice-1]);
    splice(@cols, $col_choice-1, 1);
  }
} 

print "@sort\n";

# my $sth = $dbh->prepare ("select * from $fh order by GID, ENTRY_NO");
# $sth->execute;

# while (my @row = $sth->fetchrow_array) {
#  print join(',', map{$_ // ''} @row) . "\n";
#  }

