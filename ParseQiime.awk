########################################################################
# Eric Fournier 2019-03-08                                             #
# Utilisé par Make16sSummary.sh pour le parsing des fichier Qiime      #
########################################################################

BEGIN{FS=";"}

{
K=$1;
G=$(NF-1);
split($NF,Sarr," ");
split($0,arr2," ");
S=Sarr[1];
NbReads=Sarr[2];

tax=arr2[1];
NbReads2=arr2[2];
tax=gensub(/.?__/,"","g",tax);
tax=gensub(/;/,">","g",tax)
tax=gensub(/>{2,}/,">","g",tax)

if(NR==1){
	maxreadcount=NbReads2;
}

percentread=(NbReads2/maxreadcount)*100;

#{print K,G,S,"--",NbReads,mysample}
#{
if(percentread > 1){       
	#print percentread;
	#printf "%s\t%s\t%s\t%s\t%s %s %s\n",mysample,"--","--",NbReads2,K,G,S;
	printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n",mysample,"Qiime","--","--","--",NbReads2,tax;
}
}
