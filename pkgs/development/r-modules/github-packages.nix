# This file is generated from generate-r-packages.R. DO NOT EDIT.
# Execute the following command to update the file.
#
# Rscript generate-r-packages.R github >new && mv new github-packages.nix

{ self, derive }:
let derive2 = derive { snapshot = "2020-07-28"; };
in with self; {
  lgpr = derive2 { name="lgpr"; version="0.33.2"; sha256="14i1vf9119cypjnacy43flfzx3lsjhax5zg33h4kjsyjbfl68ngi"; depends=[MASS Rcpp bayesplot ggplot2 ggpubr rstan rstantools]; url = "https://github.com/jtimonen/lgpr"; rev = "5a25fa8a1b21a34f915461802e21f592184d6e67"; };
  posterior = derive2 { name="posterior"; version="0.1.2"; sha256="1r55dy1rqxcm4cwkz6m2nv9zr73y67xv3x79rmf30pzyq3ihrfgq"; depends=[abind checkmate rlang tibble]; url = "https://github.com/stan-dev/posterior"; rev = "af3bfa0942f6ec825e8629e2d9c2cb9f7aed3400"; };
}
