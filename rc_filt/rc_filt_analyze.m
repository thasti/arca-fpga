% rc filter test bench

clear all
tc = 10;
alpha_ideal = 127/(1+tc);

in = int8(dlmread('rc_filt_test.txt'));
out_ideal = zeros(length(in)+1,1);
out_quant = int8(zeros(length(in)+1,1));
out_vhdl = int8(dlmread('rc_filt_out.txt'));

for i=1:length(in)
    out_quant(i+1) = int8(int16(out_quant(i)) + ...
        (int16(alpha_ideal) * (int16(in(i)) - int16(out_quant(i))) ...
        )/2^7);
    out_ideal(i+1) = floor((out_ideal(i) + (alpha_ideal * (double(in(i)) - out_ideal(i)))/127));
end

%stem(in)
subplot(2,1,1)
hold on
grid on
stem(out_quant(2:end),'r');
stem(out_ideal(2:end),'b');
stem(out_vhdl,'m');
subplot(2,1,2)
err = out_ideal(1:end-1)-double(out_vhdl);
hist(err,20)