package t_panda.jpg2pdf.internal;

import java.util.Optional;

/**
 * Jpgデータの解析を行うクラス
 */
public class JpgParser {
    /**
     * 指定されたバイト列をJpgデータとして解析を行う。
     * 解析の結果、Jpgデータでなかった場合、Optional.empty()が返却される
     * @param jpg_bytes Jpgデータとして解析を行うバイト列
     * @return Jpgメタデータ
     */
    public static Optional<JpgMeta> tryParse(byte[] jpg_bytes) {
        try {
            int blk_len = jpg_bytes[4] * 256 + jpg_bytes[5];
            int index = 4;
            JpgMeta.Builder meta = new JpgMeta.Builder();

            while (index + blk_len < jpg_bytes.length) {
                index += blk_len;
                if ((jpg_bytes[index] & 0xff) != 0xff) return Optional.empty();
                if ((jpg_bytes[index + 1] & 0xff) == 0xC0 || (jpg_bytes[index + 1] & 0xff) == 0xC2) {
                    meta.setWidth((jpg_bytes[index + 7] & 0xff) * 256 + (jpg_bytes[index + 8] & 0xff));
                    meta.setHeight((jpg_bytes[index + 5] & 0xff) * 256 + (jpg_bytes[index + 6] & 0xff));
                    meta.setColorSpace((jpg_bytes[index + 9]) & 0xff);
                    return Optional.of(meta.build());
                } else {
                    index += 2;
                    blk_len = (jpg_bytes[index] & 0xff) * 256 + (jpg_bytes[index + 1] & 0xff);
                }
            }

        } catch (Exception e) {
            return Optional.empty();
        }
        return Optional.empty();
    }

    public static class JpgMeta {
        public final int width, height, colorSpace;

        private JpgMeta(JpgMeta.Builder builder) {
            this.width = builder.width;
            this.height = builder.height;
            this.colorSpace = builder.colorSpace;
        }

        static class Builder {
            private int width, height, colorSpace;
            Builder() {}
            public void setWidth(int width) {this.width = width;}
            public void setHeight(int height) {this.height = height;}
            public void setColorSpace(int colorSpace) {this.colorSpace = colorSpace;}
            public JpgMeta build() {
                return new JpgMeta(this);
            }
        }

    }
}
