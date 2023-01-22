using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    public GameObject instructionsText;

    public void PlayButtonClick()
    {
        SceneManager.LoadScene("Level 1");
    }

    public void ToggleInstructions()
    {
        instructionsText.SetActive(!instructionsText.activeSelf);
    }
}
