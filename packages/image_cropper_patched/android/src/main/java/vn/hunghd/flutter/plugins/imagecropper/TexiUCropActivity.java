package vn.hunghd.flutter.plugins.imagecropper;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;

import com.yalantis.ucrop.UCropActivity;

/**
 * UCrop: padding on android.R.id.content from system bar / cutout / gesture insets
 * so toolbar and bottom actions stay usable on API 34+ edge-to-edge devices.
 */
public class TexiUCropActivity extends UCropActivity {

    private static final int INSET_TYPES =
        WindowInsetsCompat.Type.systemBars()
            | WindowInsetsCompat.Type.displayCutout()
            | WindowInsetsCompat.Type.mandatorySystemGestures();

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        super.onCreate(savedInstanceState);
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);

        final View root = findViewById(android.R.id.content);
        if (root == null) {
            return;
        }
        ViewCompat.setOnApplyWindowInsetsListener(root, (v, windowInsets) -> {
            final Insets bars = windowInsets.getInsets(INSET_TYPES);
            v.setPadding(bars.left, bars.top, bars.right, bars.bottom);
            return windowInsets;
        });
        ViewCompat.requestApplyInsets(root);
    }

    @Override
    protected void onResume() {
        super.onResume();
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
    }
}