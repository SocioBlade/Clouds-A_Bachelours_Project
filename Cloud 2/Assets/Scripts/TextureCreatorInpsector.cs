using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(PerlinTexture))]
public class TextureCreatorInspector : Editor
{
    private PerlinTexture creator;

    void OnEnable()
    {
        creator = target as PerlinTexture;
        Undo.undoRedoPerformed += RefreshCreator;    
    }

    private void OnDisable() {
        Undo.undoRedoPerformed -= RefreshCreator;
    }

    private void RefreshCreator()
    {
        if(Application.isPlaying)
        {
            creator.FillTexture();
        }
    }
    public override void OnInspectorGUI()
    {
        EditorGUI.BeginChangeCheck();
        DrawDefaultInspector();
        if(EditorGUI.EndChangeCheck() && Application.isPlaying)
        {
            RefreshCreator();
        }
    }
}