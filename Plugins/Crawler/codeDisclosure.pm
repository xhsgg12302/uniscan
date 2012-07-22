package Plugins::Crawler::codeDisclosure;

use Uniscan::Functions;
use Thread::Semaphore;
	my $func = Uniscan::Functions->new();
	our %source : shared = ();
	my $semaphore = Thread::Semaphore->new();

sub new {
    my $class    = shift;
    my $self     = {name => "Code Disclosure", version => 1.0};
	our $enabled = 1;
    return bless $self, $class;
}

sub execute {
	my $self = shift;
	my $url = shift;
	my $content = shift;
	my @codes = ('<\?php', '#include <', '#!\/usr', '#!\/bin', 'import java\.', 'public class .+\{', '<\%.+\%>', '<asp:', 'package\s\w+\;');

	
	foreach my $code (@codes){
		if($content =~ /$code/i){
			$semaphore->down();
			$source{$url}++;
			$semaphore->up();
		}
	}
}


sub showResults(){
	my $self = shift;
	$func->write("|\n| Source Code:");
	$func->writeHTMLItem("Source Code Disclosure:<br>");
	foreach my $url (%source){
		$func->write("| [+] Source Code Found: ". $url . " " . $source{$url} . "x times") if($source{$url});
		$func->writeHTMLValue("Source Code Found: ". $url) if($source{$url});
	}
}

sub getResults(){
	my $self = shift;
	return %source;
}

sub clean(){
	my $self = shift;
	%source = ();
}

sub status(){
	my $self = shift;
	return $enabled;
}

1;
