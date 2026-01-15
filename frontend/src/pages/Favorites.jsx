import { useLikedContext } from "../contexts/likedContent";
import '../css/Home.css';
import ContentCard from "../components/ContentCard"

function Favorites(){
    const { likedContent } = useLikedContext();

    if (likedContent.length > 0){
        return(
            <div className="favorites-page">
                <div className="content-grid">
                {likedContent.map((content) => (
                    <ContentCard key={content.id} content_obj={content} />
                ))}
            </div>
            </div>
        )
    }
    else{
        return(
            <div className="favorites-empty">
                <h1>No Favorites content yet</h1>
                <p>Click the heart icon on any content to add it to your favorites.</p>
            </div>
        )
    };
}

export default Favorites;