col1=[0 0.4470 0.7410];
col2=[0.6350 0.0780 0.1840];
Warm_time = 2000;
Ts = 2.0;
Ref_y = r_ts_filt.Data(Warm_time/Ts+1:end,end-1:end);
Y0 = repmat(y0(:,end-1:end),size(Ref_y,1),1);
Ref_Y = Ref_y + Y0;
Y_control = out.logsout{1}.Values.Data;
Y_control =Y_control(Warm_time/Ts+1:end,end-1:end)+Y0;
t= r_ts_filt.Time(Warm_time/Ts+1:end);
figure;
plot(t,Ref_Y(:,1),"Color",col1,"LineStyle","-.","LineWidth",2.0);
hold on;
plot(t,Y_control(:,1),"Color",col2,"LineWidth",2.0);
legend('Set Point', 'MPC',fontsize =14);
figure;
plot(t,Ref_Y(:,2),"Color",col1,"LineStyle","-.","LineWidth",2.0);
hold on;
plot(t,Y_control(:,2),"Color",col2,"LineWidth",2.0);
legend('Set point','MPC',fontsize =14);
U_Control = out.logsout{2}.Values.Data;
U0 = repmat(u0(1:end-1),size(U_Control,1),1);
U_Control = U0 + U_Control;
Y_output = [t,Ref_Y,Y_control];
writematrix(Y_output,"MPC_y1.txt");
U_output = [r_ts.Time,U_Control];
writematrix(U_output,"MPC_u1.txt");





