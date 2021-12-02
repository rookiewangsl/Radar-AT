clc;clear;close;
global  units
units  = 'km';

kraken Atten
subplot(131);  plotshd Atten.shd

krakenc Atten
subplot(132);  plotshd Atten.shd

scooter AttenS
subplot(133);  plotshd( 'AttenS.shd' )

