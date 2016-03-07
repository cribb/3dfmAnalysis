
def VST_blur_and_center_surround(image, blur_lost_and_found, center_surround, scaleopt="n")

    from scipy.ndimage.filters import gaussian_filter
    
    image = float(image)
    
    filt_blur = gaussian_filter(image, blur_lost_and_found)
    filt_cs   = gaussian_filter(image, blur_lost_and_found + center_surround)

    new_image = filt_blur - filt_cs + 0.5

    if 'scale' in scaleopt:
    	new_image = new_image - min(new_image)
    	new_image = new_image / max(new_image)


    return new_image