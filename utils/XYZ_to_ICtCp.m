function [I, Ct, Cp] = XYZ_to_ICtCp(X,Y,Z)
% https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.2100-2-201807-I!!PDF-E.pdf

RGB = XYZ_to_RGB(X,Y,Z, "rec2020", "D65", "PQ");
R=RGB(1); G=RGB(2); B=RGB(3);

L = (1688*R + 2146*G +  262*B) / 4096;
M = ( 683*R + 2951*G +  462*B) / 4096;
S = (  99*R +  309*G + 3688*B) / 4096;

L_ = linear_to_PQ(L);
M_ = linear_to_PQ(M);
S_ = linear_to_PQ(S);

I = 0.5*L_ + 0.5*M_;

Ct = ( 6610*L_ - 13613*M_ + 7003*S_) / 4096;
Cp = (17933*L_ - 17390*M_ -  543*S_) / 4096;
end