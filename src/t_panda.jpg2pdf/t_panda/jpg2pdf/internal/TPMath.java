package t_panda.jpg2pdf.internal;

public class TPMath {
    public static double nFloor(float a, int pow) {
        double keta = Math.pow(10, pow);
        double b = a * keta;
        return b / keta;
    }
}
