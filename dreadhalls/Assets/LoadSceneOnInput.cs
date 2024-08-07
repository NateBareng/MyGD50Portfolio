using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadSceneOnInput : MonoBehaviour {

	private static string _activescene;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetAxis("Submit") == 1)
		{
			_activescene = SceneManager.GetActiveScene().name;
			switch (_activescene)
			{
				case "Title":
					SceneManager.LoadScene("Play");
					break;
				case "Gameover":
					GrabPickups.Pickup = 0;
					Destroy(GameObject.Find("WhisperSource")); 
					SceneManager.LoadScene("Title");
					break;
			}
		}
	}
}
