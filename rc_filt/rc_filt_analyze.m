% rc filter test bench

clear all
tc = 20;
in = int8(dlmread('rc_filt_test.txt'));
out_ideal = zeros(length(in)+1,1);
out_quant = int8(zeros(length(in)+1,1));
out_vhdl = int8(dlmread('rc_filt_out.txt'));

for i=1:length(in)
    out_quant(i+1) = int8(int16(out_quant(i)) + ...
        (int16(tc) * (int16(in(i)) - int16(out_quant(i))) ...
        )/2^7);
    out_ideal(i+1) = floor((out_ideal(i) + (tc * (double(in(i)) - out_ideal(i)))/127));
end

%stem(in)
hold on
grid on
stem(out_quant(2:end),'r');
stem(out_vhdl,'m');
stem(out_ideal(2:end),'b');