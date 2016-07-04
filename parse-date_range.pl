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


# main
foreach (@eventos) {

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
	my $t = marcar($e{texto});

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
		return $A[0];
		say "Esto no debería ocurrir.";
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


# my $input = 'Finales llamado marzo';

sub marcar{
	my $input = $_[0];


	my @words = split /\s/, $input;
	my $verbo = $words[0];

	# if($words[2]){
	# 	$sustativo = $words[2];
	# }


	my $pre = "<div>";
	# my $classes = estandar($verbo);
	my $classes = $verbo;

	$pre = "<div class=\"".$classes."\">";
	my $post = "</div>";

	return $pre.$input.$post;
}

sub estandar{
	my $v = $_[0];
	my %verb2standar = qw(
		ins inscripciones  lla llamado  asu asueto
		cie cierre  mat cursadas  exa examenes  com comienzo
		con concluyen
	);
	return $verb2standar{ lc substr($v, 0, 3) };
}