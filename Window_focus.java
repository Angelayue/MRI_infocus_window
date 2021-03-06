import ij.measure.*;
import ij.*;
import ij.plugin.*;
import ij.process.*;
import ij.gui.*;

/**
This plugin implement the Ryall sharpness index with array
dimensions input from 3 to any odd values to set by user. The
elevation map is also included if the microscopy stage displacement
is avaliable. This version doesn't weight the effect of the corner
pixels to be the same as the orthogonal.
The composite image genrated by the plugin is improved by the
refined method according to (Goldsmith, 2000) and available at
http://www.general.monash.edu.au/ss/pdf/vol19no3/Goldsmith_03.pdf
*/
public class Window_focus implements PlugIn {

    public void run(String arg) {

        ImagePlus imp = WindowManager.getCurrentImage();
        if (imp == null) {
            IJ.noImage();
            return;
        }
        if (imp.getBitDepth()==24 || imp.getStackSize()==1) {
            IJ.error("Depth From Focus", "Non-RGB stack required");
            return;
        }

        Calibration cal = imp.getCalibration();
        double distance = cal.pixelDepth;
        GenericDialog gd = new GenericDialog("Parameters of 3D-Reconstruction");
        gd.addNumericField("Distance between slices:", distance, 3, 6, cal.getUnits());
        gd.addNumericField("Kernel size (square):", 3, 0);
        gd.showDialog();
        if (gd.wasCanceled()) return;
        distance = gd.getNextNumber()/cal.pixelWidth;
        int dimension = (int) gd.getNextNumber();
        //set mask size as half of dimension(kernel size in dialog)
        int uc = dimension / 2;
        if (dimension != (2 * uc + 1) || dimension < 3) {
            IJ.error("Depth From Focus", "Invalid Dimension!\n"
                 + "Enter odd numbers equal or greater than 3");
            return;
        }
        int vc = uc;//this is mask size
        long startTime = System.currentTimeMillis();
        ImagePlus[] output = sharpnessIndex(imp, distance, uc, vc);
        long time = System.currentTimeMillis() - startTime;
        double seconds = time / 1000.0;
        output[0].show();
        output[1].show("Reconstruction Time: " + IJ.d2s(seconds) + " seconds");
    }

    public ImagePlus[] sharpnessIndex(ImagePlus imp, double distance, int uc, int vc) {

        int width = imp.getWidth();
        int height = imp.getHeight();
        int ii, i, offset;

        float sharpness[] = new float[width * height];
        float depthimage[] = new float[width * height];

        int nSlices = imp.getStackSize();
        float[] pixels = new float[width * height]; // this the output image
        float[][] pixels2 = new float[width * height][nSlices+1];
        ImageStack stack = imp.getStack();

        IJ.resetEscape();
        IJ.showStatus("Building the elevation and composite images...");

        int[] indexmap = new int[width * height];
        for (int s = 1; s <= nSlices; s++) {
            IJ.showProgress(s, nSlices);
            if (IJ.escapePressed()) break;
            ImageProcessor ip = stack.getProcessor(s).convertToFloat();
            float[] pixels1 = (float[]) (ip.getPixels());
			//convert image to an array, re-arrange the index
            ii = 0;
            for (int y = 0; y < height; y++) {
                offset = y * width;
                for (int x = 0; x < width; x++) {
                    i = offset + x;
                    //int pix = 0xff & pixels1[i]; //
                    pixels2[ii][s] = pixels1[i];//pix;(byte)
                    ii++;
                }
            }
			//find sharpness index by std
            for (int y = vc; y < height - vc; y++) {
                for (int x = uc; x < width - uc; x++) {
                    float sum = 0;
                    for (int v = -vc; v < vc+1; v++) {
                        offset = x + (y + v) * width;
                        for (int u = -uc; u <= uc; u++) {
                        //change sharpness algorithm
                        //use window std instead of mask
                            sum += (float)Math.pow((pixels2[offset + u][s] - pixels2[x + y * width][s]),2);
                        }
                    }
                    sum = sum / (float)Math.pow((pixels2[x + y*width][s]),2);
                    if (sharpness[x + y * width] < sum) {
                        sharpness[x + y * width] = sum;
                        depthimage[x + y * width] = (float) (s * distance);
                       // pixels[x + y * width] = (float) pixels2[x + y * width];
                        indexmap[x + y * width]= (int)((indexmap[x + y * width -1] * sharpness[x + y * width -1] + s * sum)/ (sharpness[x + y * width -1] + sum));
                    }
                }
            }

        }

        for (int y = vc; y < height - vc; y++) {
            for (int x = uc; x < width - uc; x++) {
            	int idx = indexmap[x + y * width];
            	pixels[x + y * width] = (float) pixels2[x + y * width][idx];
            }
        }

        ImageProcessor ip2 = new FloatProcessor(width, height, pixels, null);
        ImagePlus imp2 = imp.createImagePlus();
        imp2.setProcessor("Composite Image", ip2);
        ImageProcessor ip3 = new FloatProcessor(width, height, depthimage, null);
        ImagePlus imp3 = imp.createImagePlus();
        imp3.setProcessor("Depth Image", ip3);
        ImagePlus[] output = new ImagePlus[2];

        output[0] = imp2;
        output[1] = imp3;
        return output;

    }

}


