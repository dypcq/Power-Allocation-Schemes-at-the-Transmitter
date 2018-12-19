%---------------------------Exact mercury/wf-------------------------------
tol=1e-5;   %Tolerance

c=0;   %Original left side
e=0;   %Original left side

d=150;  %Original right side
f=150;  %Original right side

Gamma11=0:0.1:4;
Gamma21=100*Gamma11;

Gamma1=0:0.2:8;
Gamma2=100.*Gamma1;

p1=zeros(1,length(Gamma1));
p2=zeros(1,length(Gamma1));

C_1=zeros(1,length(Gamma1));
C_2=zeros(1,length(Gamma1));
C_3=zeros(1,length(Gamma1));
C_4=zeros(1,length(Gamma1));

for n=1:length(Gamma1)
    gamma1=Gamma1(n);
    gamma2=Gamma2(n);
    
    a=gamma1*MMSE_QPSK(200*gamma1/101);  %Original left side
    b=gamma2*MMSE_QPSK(200*gamma1/101);  %Original right side
    
    %max1=-1+ceil((log(b-a)-log(tol))/log(2));   %Number of iterations
    
    %d=Bisection_QPSK(0,100,1e-5,a,gamma2);  %Original right side
    %f=Bisection_QPSK(0,100,1e-5,a,gamma2);  %Original right side
    
    for k=1:20
        eta=(a+b)/2;  %bisection
        
        %rou_1a=Bisection_QPSK(c,d,tol,a,gamma1);
        %rou_2a=Bisection_QPSK(e,f,tol,a,gamma2);
        
        %rou_1b=Bisection_QPSK(c,d,tol,b,gamma1);
        %rou_2b=Bisection_QPSK(e,f,tol,b,gamma2);
        
        rou_1e=Bisection_QPSK(c,d,tol,eta,gamma1);
        rou_2e=Bisection_QPSK(e,f,tol,eta,gamma2);
        
        %f_a=(1/(2*gamma1))*rou_1a+(1/(2*gamma2))*rou_2a-1;
        %f_b=(1/(2*gamma1))*rou_1b+(1/(2*gamma2))*rou_2b-1;
        f_e=(1/(2*gamma1))*rou_1e+(1/(2*gamma2))*rou_2e-1;
        
        if f_e==0   %Find the optimal point
            p1(n)=rou_1e/gamma1;
            p2(n)=rou_2e/gamma2;
            break
        elseif f_e<0
            b=eta;
        else
            a=eta;
        end
        if abs(f_e)<1e-3
            p1(n)=rou_1e/gamma1;
            p2(n)=rou_2e/gamma2;
            break
        end
    end
end

%------------------------High Power Approximation--------------------------


p11=zeros(1,length(Gamma11));
p21=zeros(1,length(Gamma21));

for n1=1:length(Gamma11)
    gamma11=Gamma1(n1);
    gamma21=Gamma2(n1);
    
    a1=0;  %Original left side
    b1=2;  %Original right side
    max1=-1+ceil((log(b1-a1)-log(tol))/log(2));   %Number of iterations
    
    for k1=1:max1+1
        eta1=(a1+b1)/2;  %bisection
        
        %rou_1a1=High_Power100(gamma11,a1);
        %rou_1b1=High_Power100(gamma11,b1);
        rou_1e1=High_Power100(gamma11,eta1);
        
        if rou_1e1==0   %Find the optimal point
            p11(n1)=2-eta1;
            p21(n1)=eta1;
            break
        elseif rou_1e1>0
            b1=eta1;
        else
            a1=eta1;
        end
        if b1-a1<tol
            p11(n1)=2-eta1;
            p21(n1)=eta1;
            break
        end
    end
end

%----------------------Constallation Constrained WF------------------------
p=0:0.2:8;
Pt=2;  %Total power

g1=1;
g2=100;  %Channel gain

M=4;  %Constellation order
tol=1e-5;   %Tolerance

p_1=zeros(1,length(p));
p_2=zeros(1,length(p));

%-----------------------------Constellation WF-----------------------------
for n=1:length(p)
    a=0;   %Original left side
    b=g2*(1-1/M);   %Original right side
    max1=-1+ceil((log(b-a)-log(tol))/log(2));   %Number of iterations
    
    gamma1=Gamma1(n);
    gamma2=Gamma2(n);
    
    for k=1:max1+1
        lamda=(a+b)/2;   %Bisection
        %p_1a=constellation1(p(n),g1,M,a);   %Power allocation at a
        %p_2a=constellation1(p(n),g2,M,a);
        
        %p_1b=constellation1(p(n),g1,M,b);   %Power allocation at b
        %p_2b=constellation1(p(n),g2,M,b);
        
        p_1l=constellation1(p(n),g1,M,lamda);   %Power allocation at lamda
        p_2l=constellation1(p(n),g2,M,lamda);
        
        %fa=p_1a+p_2a-Pt;
        %fb=p_1b+p_2b-Pt;
        fl=p_1l+p_2l-Pt;
        
        if fl==0   %Find the optimal point
            p_1(n)=p_1l;
            p_2(n)=p_2l;
            break
        elseif fl<0
            b=lamda;
        else
            a=lamda;
        end
        if b-a<tol
            p_1(n)=p_1l;
            p_2(n)=p_2l;
            break
        end
    end
end
%-------------------------Monte Carlo for OPA------------------------------
p15=unifrnd(0,2,1000,1); %Uniform distributed
%p15=0.001:0.001:2;
p25=2-p15;

N=10000;
z=normrnd(0,1,N,1);  % Gaussian random variable

C_25=zeros(1,length(Gamma1));
p51=zeros(1,length(Gamma1));
p52=zeros(1,length(Gamma1));
for n=1:length(Gamma1)
    sigma1=sqrt(1/Gamma11(n));
    sigma2=sqrt(1/Gamma21(n));
    
    C_2_15=zeros(1,length(p15));
    C_2_25=zeros(1,length(p15));
    C=zeros(1,length(p15));
    for k=1:length(p15)
        d_2_1=[0:1;
            -1:0]'*2*sqrt(p15(k));  % Distance matrix
        d_2_2=[0:1;
            -1:0]'*2*sqrt(p25(k));  % Distance matrix
        
        z1=sigma1*z;
        z2=sigma2*z;
        
        f1=zeros(length(d_2_1),1);
        b1=zeros(1,length(d_2_1));
        x1=zeros(N,1);
        
        f2=zeros(length(d_2_2),1);
        b2=zeros(1,length(d_2_2));
        x2=zeros(N,1);
        %--------------------------------p1------------------------------------
        for m=1:N  % Number of pages
            for j=1:length(d_2_1)  % Number of columns
                for i=1:length(d_2_1)  % Number of rows
                    f1(i)=exp(-d_2_1(i,j)^2/(2*sigma1^2)-z1(m)*d_2_1(i,j)/sigma1^2);
                end
                b1(j)=log(sum(f1))/log(2);  % First sum over i
            end
            x1(m)=sum(b1);  % Second sum over j
        end
        C_2_15(k)=2-mean(x1);  % Capacity of QPSK
        %--------------------------------p2------------------------------------
        for m=1:N  % Number of pages
            for j=1:length(d_2_2)  % Number of columns
                for i=1:length(d_2_2)  % Number of rows
                    f2(i)=exp(-d_2_2(i,j)^2/(2*sigma2^2)-z2(m)*d_2_2(i,j)/sigma2^2);
                end
                b2(j)=log(sum(f2))/log(2);  % First sum over i
            end
            x2(m)=sum(b2);  % Second sum over j
        end
        C_2_25(k)=2-mean(x2);  % Capacity of QPSK
        C(k)=C_2_15(k)+C_2_25(k);
    end
    [C_25(n),b]=max(C);
    p51(n)=p15(b);
    p52(n)=p25(b);
end

plot(Gamma1,p1)
hold on
grid on
plot(Gamma1,p11,'.')
plot(Gamma1,p_1,'--')
plot(Gamma1,p51,'-.')

plot(Gamma1,p2)
plot(Gamma1,p21,'.')
plot(Gamma1,p_2,'--')
plot(Gamma1,p52,'-.')
ylim([0 2])

xlabel('P')
ylabel('Power Allocation')
legend('Exact mercury/waterfilling','High-Power Approximation','AOPA','Monte Carlo OPA')