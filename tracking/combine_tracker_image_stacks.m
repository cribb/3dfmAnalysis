function combined_stack = combine_tracker_image_stacks(tracker_stack_struct_array)

if nargin < 1 || isempty(tracker_stack_struct_array)
    error('No data found.');
end

tssa = tracker_stack_struct_array;

vout = tssa(1).vid_table;
sout = tssa(1).stack;

for k = 2 : length(tssa)
    vout = cat(1, vout, tssa(k).vid_table);
    sout = cat(3, sout, tssa(k).stack);
end

combined_stack.halfsize = tssa(1).halfsize;
combined_stack.vid_table = vout;
combined_stack.stack = sout;

return;

