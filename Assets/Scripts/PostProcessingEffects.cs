using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessingEffects : MonoBehaviour
{
    [SerializeField] private Material _PostProcessingMaterial;

    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        Graphics.Blit(source, destination, _PostProcessingMaterial);
    }
}
