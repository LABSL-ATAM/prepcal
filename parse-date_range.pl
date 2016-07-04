use strict;
use warnings;
use feature 'say';
use Data::Dumper;


use DateTime;
use File::Slurp;

use HTML::Entities;



my @file = read_file('c.txt') ;
my $anio = 2016;

my @lines = grep {!/^#/} @file;		# weed out comments
my @eventos = grep {/\S/} @lines;	# weed out blank lines

my $contador = 0;
# main
foreach (@eventos) {
	$contador++;

	if (index($_, '*') == 0) { # estas lineas (*) pasan derecho
		my $new = substr $_, 1;
		$new =~ s/^\s*(.*?)\s*$/$1/;
		say $new;
		next;
	}

	my ($fechas,$texto) = split /:/,$_, 2;
	my ($inicio,$final) = split /al/,$fechas;
	my @inicio = split /de/,$inicio;

	$texto =~ s/^\s*(.*?)\s*$/$1/;

	if($final){
		my @final = split /de/, $final;

		if(!$inicio[1]){
			$inicio[1] = $final[1]; # agrego mes si no lo tiene al inicio
		}

		my %i = fecha(@inicio);
		my %f = fecha(@final);
		my %evento = (start => {%i},end => {%f},texto => $texto);
		salida(%evento);
	}else{
		my %i = fecha(@inicio);
		my %evento = (start => {%i},texto => $texto);
		salida(%evento);
	}

}

# subs
sub salida{
	my (%e) = @_;
	my $d1 = DateTime->new($e{start});
	my $t = indentificar($e{texto});

	if($e{end}){
		say "# ".$e{texto};

		my $d2 = DateTime->new($e{end});

		while ($d1 <= $d2) { # mientras que el comienzo no sea mas grande...

			if($d1->day_of_week < 6 ){ # si NO es sabado o domingo
				say $d1->strftime("%d/%m"), "	",$t;
			}
			$d1->add(days => 1); # siguiente 1 dia
		}

		print '#' for 1 .. 20;	say "\n";
	}else{
		say $d1->strftime("%d/%m"), "	", $t;
	}

}

sub fecha{
	my @A = grep(s/(^\s+|\s+$)//g, @_);  # borro espacios

	if($A[1]){
		my $m = mes($A[1]);
		my %fecha = (day  => $A[0], month => $m, year => $anio);
		return %fecha;
	}else{ # fecha sin mes
		die "Evento: ",$contador," ¡No puede haber una fecha sin MES!";
	}

}

sub mes{
	my $month = $_[0];
	my %mon2num = qw(
		ene 1  feb 2  mar 3  abr 4  may 5  jun 6
		jul 7  ago 8  sep 9  oct 10 nov 11 dic 12
	);
	return $mon2num{ lc substr($month, 0, 3) };
}


my @gw;
# print Dumper (@gw);
sub indentificar{
	# my $raw_input = $_[0];
	my @input = split /\(/, $_[0],2; # separo al "(" (parantesis)

	my @words = split /\W/,$input[0]; # separo al " " (espacio)

	my $first = $words[0];
	my $last = $words[@words - 1];
	push(@gw, $last) unless grep{$_ eq $last} @gw;

	my $classes = lc $first.' '.$last;
	my $pre = "<div class=\"".$classes."\">";
	my $post = "</div>";

	return $pre.$_[0].$post;
}

